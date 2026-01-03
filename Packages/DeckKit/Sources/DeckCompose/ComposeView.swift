import SwiftUI
import DeckServices

struct ComposeView: View {
  @StateObject private var state: ComposeViewState
  private let interactor: ComposeBusinessLogic

  init(state: ComposeViewState, interactor: ComposeBusinessLogic) {
    _state = StateObject(wrappedValue: state)
    self.interactor = interactor
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          if state.accounts.isEmpty {
            ContentUnavailableView("No Accounts", systemImage: "person.crop.circle.badge.plus")
          } else {
            Picker("Account", selection: $state.selectedAccountId) {
              ForEach(state.accounts) { account in
                VStack(alignment: .leading) {
                  Text(account.title)
                  Text(account.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .tag(Optional(account.id))
              }
            }
          }
        }

        Section("Post") {
          TextEditor(text: $state.text)
            .frame(minHeight: 160)

          Picker("Visibility", selection: $state.visibility) {
            ForEach(PostingVisibility.allCases) { visibility in
              Text(visibility.displayName).tag(visibility)
            }
          }
        }
      }
      .navigationTitle("Compose")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Post") {
            Task {
              let request = ComposeModels.Submit.Request(
                text: state.text,
                visibility: state.visibility,
                accountId: state.selectedAccountId
              )
              await interactor.submitPost(request)
            }
          }
          .disabled(state.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || state.selectedAccountId == nil || state.isLoading)
        }
      }
      .overlay {
        if state.isLoading {
          ProgressView()
        }
      }
      .task {
        await interactor.loadAccounts()
      }
      .alert("Error", isPresented: Binding(
        get: { state.errorMessage != nil },
        set: { _ in state.errorMessage = nil }
      )) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(state.errorMessage ?? "Unknown error")
      }
      .alert("Posted", isPresented: Binding(
        get: { state.successMessage != nil },
        set: { _ in state.successMessage = nil }
      )) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(state.successMessage ?? "Posted successfully.")
      }
    }
  }
}
