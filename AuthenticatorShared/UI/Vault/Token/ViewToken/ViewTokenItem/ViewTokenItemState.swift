import BitwardenSdk
import Foundation

// MARK: - ViewTokenItemState

struct ViewTokenItemState: Sendable {
    // MARK: Properties

    /// The TOTP key.
    var authenticatorKey: String?

    /// The TOTP key/code state.
    var totpState: LoginTOTPState
}

extension ViewTokenItemState {
    var totpCode: TOTPCodeModel? {
        totpState.codeModel
    }
}
