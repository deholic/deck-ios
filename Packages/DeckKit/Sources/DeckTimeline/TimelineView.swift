import SwiftUI

struct TimelineView: View {
  @StateObject private var state: TimelineViewState
  private let interactor: TimelineBusinessLogic
  @State private var replyTarget: TimelinePostViewModel?

  init(state: TimelineViewState, interactor: TimelineBusinessLogic) {
    _state = StateObject(wrappedValue: state)
    self.interactor = interactor
  }

  var body: some View {
    NavigationStack {
      List {
        if state.accounts.isEmpty {
          ContentUnavailableView("No Accounts", systemImage: "person.crop.circle.badge.plus")
        } else if state.posts.isEmpty {
          ContentUnavailableView("No Posts", systemImage: "list.bullet.rectangle")
        } else {
          ForEach(state.posts) { post in
            TimelinePostRow(
              post: post,
              onReply: { replyTarget = post },
              onBoost: { Task { await interactor.toggleBoost(postId: post.id) } },
              onFavorite: { Task { await interactor.toggleFavorite(postId: post.id) } },
              onBookmark: { Task { await interactor.toggleBookmark(postId: post.id) } },
              onReaction: { reaction in Task { await interactor.setReaction(postId: post.id, reaction: reaction) } },
              onClearReaction: { Task { await interactor.clearReaction(postId: post.id) } }
            )
          }
        }
      }
      .listStyle(.plain)
      .overlay {
        if state.isLoading {
          ProgressView()
        }
      }
      .navigationTitle("Timeline")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          if state.isStreaming {
            Label("Live", systemImage: "dot.radiowaves.left.and.right")
              .labelStyle(.titleAndIcon)
              .foregroundStyle(.green)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          if !state.accounts.isEmpty {
            Menu {
              Picker("Account", selection: Binding(
                get: { state.selectedAccountId ?? UUID() },
                set: { id in Task { await interactor.selectAccount(id: id) } }
              )) {
                ForEach(state.accounts) { account in
                  Text("\(account.title) · \(account.subtitle)").tag(account.id)
                }
              }
            } label: {
              Label("Account", systemImage: "person.crop.circle")
            }
          }
        }
      }
      .refreshable {
        await interactor.refresh()
      }
      .task {
        await interactor.load()
      }
      .alert("Error", isPresented: Binding(
        get: { state.errorMessage != nil },
        set: { _ in state.errorMessage = nil }
      )) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(state.errorMessage ?? "Unknown error")
      }
      .sheet(item: $replyTarget) { post in
        ReplyComposerView(post: post, interactor: interactor)
      }
    }
  }
}

private struct TimelinePostRow: View {
  let post: TimelinePostViewModel
  let onReply: () -> Void
  let onBoost: () -> Void
  let onFavorite: () -> Void
  let onBookmark: () -> Void
  let onReaction: (String) -> Void
  let onClearReaction: () -> Void

  private let reactionOptions = ["👍", "❤️", "🎉", "😂", "😮", "👀"]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let boostedBy = post.boostedBy {
        Label("Boosted by \(boostedBy)", systemImage: "arrow.2.squarepath")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      HStack(alignment: .top, spacing: 12) {
        AsyncImage(url: post.avatarURL) { image in
          image.resizable()
        } placeholder: {
          Circle().fill(Color.gray.opacity(0.3))
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())

        VStack(alignment: .leading, spacing: 6) {
          HStack {
            Text(post.authorName)
              .font(.headline)
            Text(post.authorHandle)
              .font(.subheadline)
              .foregroundStyle(.secondary)
            Spacer()
            Text(post.createdAt)
              .font(.caption)
              .foregroundStyle(.secondary)
          }

          Text(post.content)
            .font(.body)
            .foregroundStyle(.primary)
        }
      }

      HStack(spacing: 16) {
        Button(action: onReply) {
          Label("\(post.replyCount)", systemImage: "bubble.left")
        }
        .buttonStyle(.borderless)

        Button(action: onBoost) {
          Label("\(post.boostCount)", systemImage: "arrow.2.squarepath")
        }
        .buttonStyle(.borderless)
        .foregroundStyle(post.isBoosted ? .green : .primary)

        Button(action: onFavorite) {
          Label("\(post.favoriteCount)", systemImage: post.isFavorited ? "heart.fill" : "heart")
        }
        .buttonStyle(.borderless)
        .foregroundStyle(post.isFavorited ? .pink : .primary)

        if post.service == .mastodon {
          Button(action: onBookmark) {
            Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
          }
          .buttonStyle(.borderless)
          .foregroundStyle(post.isBookmarked ? .orange : .primary)
        }

        if post.canReact {
          Menu {
            ForEach(reactionOptions, id: \.self) { reaction in
              Button(reaction) { onReaction(reaction) }
            }
            Divider()
            Button("Clear Reaction") { onClearReaction() }
              .disabled(!post.reactions.contains(where: { $0.isMine }))
          } label: {
            Image(systemName: "face.smiling")
          }
          .buttonStyle(.borderless)
        }

        if let url = post.url {
          ShareLink(item: url) {
            Image(systemName: "square.and.arrow.up")
          }
          .buttonStyle(.borderless)
        }
      }
      .font(.caption)

      if post.canReact, !post.reactions.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(post.reactions) { reaction in
              Button {
                if reaction.isMine {
                  onClearReaction()
                } else {
                  onReaction(reaction.name)
                }
              } label: {
                Text("\(reaction.name) \(reaction.count)")
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(reaction.isMine ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.2))
                  .clipShape(Capsule())
              }
              .buttonStyle(.plain)
            }
          }
        }
      }
    }
    .padding(.vertical, 8)
  }
}

private struct ReplyComposerView: View {
  let post: TimelinePostViewModel
  let interactor: TimelineBusinessLogic
  @Environment(\.dismiss) private var dismiss
  @State private var text = ""
  @State private var isSending = false

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 16) {
        Text("Replying to \(post.authorHandle)")
          .font(.headline)
        TextEditor(text: $text)
          .frame(minHeight: 160)
          .padding(8)
          .background(Color.secondary.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: 12))
        Spacer()
      }
      .padding()
      .navigationTitle("Reply")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Send") {
            Task {
              isSending = true
              defer { isSending = false }
              await interactor.reply(.init(postId: post.id, text: text))
              dismiss()
            }
          }
          .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
      }
    }
  }
}
