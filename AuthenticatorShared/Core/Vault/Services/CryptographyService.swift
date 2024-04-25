import CryptoKit
import Foundation

// MARK: - CryptographyService

/// A protocol for a `CryptographyService` which manages encrypting and decrypting `AuthenticationItem` objects
///
protocol CryptographyService {
    func encrypt(_ authenticatorItemView: AuthenticatorItemView) async throws -> AuthenticatorItem

    func decrypt(_ authenticatorItem: AuthenticatorItem) async throws -> AuthenticatorItemView
}

class DefaultCryptographyService: CryptographyService {
    // MARK: Properties

    /// A service to get the encryption secret key
    ///
    let cryptographyKeyService: CryptographyKeyService

    // MARK: Initialization

    init(
        cryptographyKeyService: CryptographyKeyService
    ) {
        self.cryptographyKeyService = cryptographyKeyService
    }

    // MARK: Methods

    func encrypt(_ authenticatorItemView: AuthenticatorItemView) async throws -> AuthenticatorItem {
        let secretKey = try await cryptographyKeyService.getOrCreateSecretKey(userId: "local")
        guard let totpKeyData = authenticatorItemView.totpKey?.data(using: .utf8) else {
            throw CryptographyError.unableToRetrieveTotpKey
        }

        let encryptedSealedBox = try AES.GCM.seal(
            totpKeyData,
            using: secretKey
        )

        guard let text = encryptedSealedBox.combined?.base64EncodedString() else {
            throw CryptographyError.unableToSerializeSealedBox
        }

        return AuthenticatorItem(
            favorite: authenticatorItemView.favorite,
            id: authenticatorItemView.id,
            name: authenticatorItemView.name,
            totpKey: text,
            username: authenticatorItemView.username
        )
    }

    func decrypt(_ authenticatorItem: AuthenticatorItem) async throws -> AuthenticatorItemView {
        let secretKey = try await cryptographyKeyService.getOrCreateSecretKey(userId: "local")

        guard let totpKey = authenticatorItem.totpKey,
              let totpKeyData = Data(base64Encoded: totpKey)
        else {
            throw CryptographyError.unableToRetrieveTotpKey
        }

        let encryptedSealedBox = try AES.GCM.SealedBox(
            combined: totpKeyData
        )

        let decryptedBox = try AES.GCM.open(
            encryptedSealedBox,
            using: secretKey
        )

        return AuthenticatorItemView(
            favorite: authenticatorItem.favorite,
            id: authenticatorItem.id,
            name: authenticatorItem.name,
            totpKey: String(data: decryptedBox, encoding: .utf8),
            username: authenticatorItem.username
        )
    }

    // MARK: Private Methods

    func encryptData(_ data: Data, withKey secretKey: SymmetricKey) throws -> String {
        let encryptedSealedBox = try AES.GCM.seal(
            data,
            using: secretKey
        )

        guard let text = encryptedSealedBox.combined?.base64EncodedString() else {
            throw CryptographyError.unableToSerializeSealedBox
        }

        return text
    }

    func decryptData(_ data: Data, withKey secretKey: SymmetricKey) throws -> String? {
        let encryptedSealedBox = try AES.GCM.SealedBox(
            combined: data
        )

        let decryptedBox = try AES.GCM.open(
            encryptedSealedBox,
            using: secretKey
        )

        return String(data: decryptedBox, encoding: .utf8)
    }
}

// MARK: - CryptographyError

enum CryptographyError: Error {
    case unableToParseSecretKey
    case unableToRetrieveTotpKey
    case unableToSerializeSealedBox
}
