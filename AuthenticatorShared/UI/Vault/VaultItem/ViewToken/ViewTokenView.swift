import BitwardenSdk
import SwiftUI

// MARK: - ViewTokenView

/// A view that displays the information for a token.
struct ViewTokenView: View {
    // MARK: Private Properties

    // MARK: Properties

    /// The `Store` for this view.
    @ObservedObject var store: Store<ViewTokenState, ViewTokenAction, ViewTokenEffect>

    /// The `TimeProvider` used to calculate TOTP expiration.
    var timeProvider: any TimeProvider

    // MARK: View

    var body: some View {
        LoadingView(state: store.state.loadingState) { state in
            details(for: state)
        }
        .background(Asset.Colors.backgroundSecondary.swiftUIColor.ignoresSafeArea())
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toast(store.binding(
            get: \.toast,
            send: ViewTokenAction.toastShown
        ))
        .task {
            await store.perform(.appeared)
        }
    }

    /// The title of the view
    private var navigationTitle: String {
        Localizations.viewItem
    }

    // MARK: Private Views

    /// The details of the token.
    @ViewBuilder
    private func details(for state: TokenItemState) -> some View {
        Text("Hello world")
    }
}

// MARK: Previews

#if DEBUG

#Preview("Loading") {
    NavigationView {
        ViewTokenView(
            store: Store(
                processor: StateProcessor(
                    state: ViewTokenState(
                        loadingState: .loading(nil)
                    )
                )
            ),
            timeProvider: PreviewTimeProvider(
                fixedDate: Date(timeIntervalSinceReferenceDate: 0)
            )
        )
    }
}

#endif
