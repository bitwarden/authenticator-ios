import BitwardenSdk
import Foundation

/// Data model for an item displayed in the item list.
///
public struct ItemListItem: Equatable, Identifiable {
    /// The identifier for the item.
    public let id: String

    /// The name to display for the item.
    public let name: String

    /// The token used to generate the code.
    public let token: Token

    /// The current TOTP code for the ciper.
    public var totpCode: TOTPCodeModel
}

extension ItemListItem {
    /// Initialize an `ItemListItem` from an `AuthenticatorItemView`
    ///
    /// - Parameters:
    ///   - authenticatorItemView: The `AuthenticatorItemView` used to initialize the `ItemListItem`
    ///
    init?(authenticatorItemView: AuthenticatorItemView) {
        self.init(
            id: authenticatorItemView.id,
            name: authenticatorItemView.name,
            token: Token(
                id: "Bad",
                name: "Bad",
                authenticatorKey: "Bad"
            )!,
            totpCode: TOTPCodeModel(
                code: "123456",
                codeGenerationDate: .now,
                period: 30
            )
        )
    }
}
