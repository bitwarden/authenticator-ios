import SwiftUI

// MARK: - TutorialView

/// A view containing the tutorial screens
///
struct TutorialView: View {
    // MARK: Properties

    /// The `Store` for this view.
    @ObservedObject var store: Store<TutorialState, TutorialAction, TutorialEffect>

    // MARK: View

    var body: some View {
        Text("Hello World")
    }
}
