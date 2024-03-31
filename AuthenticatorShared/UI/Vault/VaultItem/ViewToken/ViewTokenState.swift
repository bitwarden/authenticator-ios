import BitwardenSdk
import Foundation

// MARK: - ViewTokenState

/// A `Sendable` type used to describe the state of a `ViewTokenView`
struct ViewTokenState: Sendable {
    // MARK: Properties

    /// The current state. If this state is not `.loading`, this value will contain an associated value with the
    /// appropriate internal state.
    var loadingState: LoadingState<TokenItemState> = .loading(nil)

    /// A toast message to show in the view.
    var toast: Toast?
}

struct TokenItemState: Equatable {

}
