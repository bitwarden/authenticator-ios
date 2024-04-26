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

        guard let encryptedName = try encryptString(authenticatorItemView.name, withKey: secretKey) else {
            throw CryptographyError.unableToEncryptRequiredField
        }

        return try AuthenticatorItem(
            favorite: authenticatorItemView.favorite,
            id: authenticatorItemView.id,
            name: encryptedName,
            totpKey: encryptString(authenticatorItemView.totpKey, withKey: secretKey),
            username: encryptString(authenticatorItemView.username, withKey: secretKey)
        )
    }

    func decrypt(_ authenticatorItem: AuthenticatorItem) async throws -> AuthenticatorItemView {
        let secretKey = try await cryptographyKeyService.getOrCreateSecretKey(userId: "local")

        return try AuthenticatorItemView(
            favorite: authenticatorItem.favorite,
            id: authenticatorItem.id,
            name: decryptString(authenticatorItem.name, withKey: secretKey) ?? "",
            totpKey: decryptString(authenticatorItem.totpKey, withKey: secretKey),
            username: decryptString(authenticatorItem.username, withKey: secretKey)
        )
    }

    // MARK: Private Methods

    func encryptString(_ string: String?, withKey secretKey: SymmetricKey) throws -> String? {
        guard let data = string?.data(using: .utf8) else {
            return nil
        }

        let encryptedSealedBox = try AES.GCM.seal(
            data,
            using: secretKey
        )

        return encryptedSealedBox.combined?.base64EncodedString()
    }

    func decryptString(_ string: String?, withKey secretKey: SymmetricKey) throws -> String? {
        guard let string, let data = Data(base64Encoded: string) else {
            return nil
        }

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
    case unableToEncryptRequiredField
    case unableToParseSecretKey
    case unableToReadEncryptedData
    case unableToReadDecryptedData
    case unableToRetrieveTotpKey
    case unableToSerializeSealedBox
}
