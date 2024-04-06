import Foundation

@testable import AuthenticatorShared

class MockCryptographyService: CryptographyService {
    var encryptError: Error?
    var encryptedAuthenticatorItems = [AuthenticatorItemView]()

    func encrypt(_ authenticatorItemView: AuthenticatorItemView) async throws -> AuthenticatorItem {
        AuthenticatorItem(authenticatorItemView: authenticatorItemView)
    }

    func decrypt(_ authenticatorItem: AuthenticatorItem) async throws -> AuthenticatorItemView {
        AuthenticatorItemView(authenticatorItem: authenticatorItem)
    }
}
