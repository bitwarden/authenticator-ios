import SwiftUI

// MARK: - ItemsView

/// A view that displays the items in a single vault group.
struct ItemsView: View {
    // MARK: Properties

    /// An object used to open urls from this view.
    @Environment(\.openURL) private var openURL

    /// The `Store` for this view.
    @ObservedObject var store: Store<ItemsState, ItemsAction, ItemsEffect>

    /// The `TimeProvider` used to calculate TOTP expiration.
    var timeProvider: any TimeProvider

    // MARK: View

    var body: some View {
        content
            .navigationTitle("Hello from the Token List View")
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
        ItemsView(
            store: Store(
                processor: StateProcessor(
                    state: ItemsState(
                        loadingState: .loading(nil)
                    )
                )
            ),
            timeProvider: PreviewTimeProvider()
        )
    }
}
#endif
