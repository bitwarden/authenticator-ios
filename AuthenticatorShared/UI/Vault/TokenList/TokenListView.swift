import SwiftUI

// MARK: - TokenListView

/// A view that displays the items in a single vault group.
struct TokenListView: View {
    // MARK: Properties

    /// An object used to open urls from this view.
    @Environment(\.openURL) private var openURL

    /// The `Store` for this view.
    @ObservedObject var store: Store<TokenListState, TokenListAction, TokenListEffect>

    /// The `TimeProvider` used to calculate TOTP expiration.
    var timeProvider: any TimeProvider

    // MARK: View

    var body: some View {
        content
            .navigationTitle("Hello")
            .navigationBarTitleDisplayMode(.inline)
            .background(Asset.Colors.backgroundSecondary.swiftUIColor.ignoresSafeArea())
            .toolbar {
                addToolbarItem(hidden: !store.state.showAddToolbarItem) {
                    store.send(.addItemPressed)
                }
            }
            .task {
                await store.perform(.appeared)
            }
    }

    // MARK: Private

    @ViewBuilder private var content: some View {
        Text("Hello world")
    }
}

// MARK: Previews

#if DEBUG
#Preview("Loading") {
    NavigationView {
        TokenListView(
            store: Store(
                processor: StateProcessor(
                    state: TokenListState(
                        loadingState: .loading(nil)
                    )
                )
            ),
            timeProvider: PreviewTimeProvider()
        )
    }
}
#endif
