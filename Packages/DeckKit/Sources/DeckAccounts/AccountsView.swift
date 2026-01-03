import SwiftUI
import DeckServices

struct AccountsView: View {
  @StateObject private var state: AccountsViewState
  private let interactor: AccountsBusinessLogic
  @State private var isPresentingAdd = false

  init(state: AccountsViewState, interactor: AccountsBusinessLogic) {
    _state = StateObject(wrappedValue: state)
    self.interactor = interactor
  }

  var body: some View {
    NavigationStack {
      List {
        if state.accounts.isEmpty {
          ContentUnavailableView("No Accounts", systemImage: "person.crop.circle.badge.plus")
        } else {
          ForEach(state.accounts) { account in
            VStack(alignment: .leading, spacing: 4) {
              Text(account.title)
                .font(.headline)
              Text(account.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
          }
          .onDelete { indices in
            for index in indices {
              let accountId = state.accounts[index].id
              Task { await interactor.removeAccount(id: accountId) }
            }
          }
        }
      }
      .overlay {
        if state.isLoading {
          ProgressView()
        }
      }
      .navigationTitle("Accounts")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            isPresentingAdd = true
          } label: {
            Label("Add Account", systemImage: "plus")
          }
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
      .sheet(isPresented: $isPresentingAdd) {
        AddAccountView(interactor: interactor)
      }
    }
  }
}

struct AddAccountView: View {
  private let interactor: AccountsBusinessLogic
  @Environment(\.dismiss) private var dismiss
  @State private var service: AccountServiceType = .mastodon
  @State private var instance = ""
  @State private var isWorking = false
  @State private var errorMessage: String?

  private let webAuthentication = WebAuthenticationSession()

  init(interactor: AccountsBusinessLogic) {
    self.interactor = interactor
  }

  var body: some View {
    NavigationStack {
      Form {
        Picker("Service", selection: $service) {
          ForEach(AccountServiceType.allCases) { service in
            Text(service.displayName).tag(service)
          }
        }

        TextField("Instance (e.g. social.example)", text: $instance)
          .textContentType(.URL)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
      }
      .navigationTitle("Add Account")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Connect") {
            Task { await connect() }
          }
          .disabled(instance.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isWorking)
        }
      }
      .overlay {
        if isWorking {
          ProgressView()
        }
      }
      .alert("Error", isPresented: Binding(
        get: { errorMessage != nil },
        set: { _ in errorMessage = nil }
      )) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(errorMessage ?? "Unknown error")
      }
    }
  }

  private func connect() async {
    isWorking = true
    defer { isWorking = false }

    guard let session = await interactor.startAuthentication(service: service, instance: instance) else {
      errorMessage = AuthenticationError.invalidInstance.localizedDescription
      return
    }

    do {
      let callbackURL = try await webAuthentication.start(url: session.authorizationURL, callbackScheme: session.callbackScheme)
      await interactor.finishAuthentication(session: session, callbackURL: callbackURL)
      dismiss()
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
