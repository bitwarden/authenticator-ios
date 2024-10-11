import Foundation

@testable import AuthenticatorBridgeKit

extension AuthenticatorBridgeItemDataView {
    static func fixture(
        accountDomain: String? = "Domain",
        accountEmail: String? = "test@example.com",
        favorite: Bool = false,
        id: String = UUID().uuidString,
        name: String = "Name",
        totpKey: String? = "TOTP",
        username: String? = "username"
    ) -> AuthenticatorBridgeItemDataView {
        AuthenticatorBridgeItemDataView(
            accountDomain: accountDomain,
            accountEmail: accountEmail,
            favorite: favorite,
            id: id,
            name: name,
            totpKey: totpKey,
            username: username
        )
    }

    static func fixtures() -> [AuthenticatorBridgeItemDataView] {
        [
            AuthenticatorBridgeItemDataView.fixture(),
            AuthenticatorBridgeItemDataView.fixture(favorite: true),
            AuthenticatorBridgeItemDataView.fixture(accountDomain: "https://vault.example.com"),
            AuthenticatorBridgeItemDataView.fixture(accountEmail: "bw@example.com"),
            AuthenticatorBridgeItemDataView.fixture(totpKey: "TOTP"),
            AuthenticatorBridgeItemDataView.fixture(username: "Username"),
            AuthenticatorBridgeItemDataView.fixture(totpKey: "TOTP", username: "Username"),
            AuthenticatorBridgeItemDataView.fixture(accountEmail: ""),
            AuthenticatorBridgeItemDataView.fixture(totpKey: ""),
            AuthenticatorBridgeItemDataView.fixture(username: ""),
            AuthenticatorBridgeItemDataView.fixture(totpKey: "", username: ""),
        ]
    }
}
