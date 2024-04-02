import BitwardenSdk
import Foundation

// MARK: - ViewTokenItemState

// The state for viewing/adding/editing a token item
struct ViewTokenItemState: Sendable {
    // MARK: Properties

    /// The TOTP key.
    var authenticatorKey: String?

    /// A toast message to show in the view.
    var toast: Toast?

    /// The TOTP key/code state.
    var totpState: LoginTOTPState
}

extension ViewTokenItemState {
    var totpCode: TOTPCodeModel? {
        totpState.codeModel
    }
}
