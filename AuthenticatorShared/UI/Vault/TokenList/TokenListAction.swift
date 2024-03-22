// MARK: - TokenListAction

/// Actions that can be processed by a `TokenListProcessor`.
enum TokenListAction: Equatable {
    /// The add item button was pressed.
    ///
    case addItemPressed

    /// The url has been opened so clear the value in the state.
    case clearURL

    /// The copy TOTP Code button was pressed.
    ///
    case copyTOTPCode(_ code: String)

    /// The toast was shown or hidden.
    case toastShown(Toast?)
}
