import BitwardenSdk
import Foundation

/// The state of an `EditTokenView`
protocol EditTokenState: Sendable {
    // MARK: Properties

    /// The Add or Existing Configuration.
    var configuration: TokenItemState.Configuration { get }

    /// The name of this item.
    var name: String { get set }

    /// A toast for views
    var toast: Toast? { get set }

    /// The TOTP key/code state.
    var totpState: LoginTOTPState { get set }
}
