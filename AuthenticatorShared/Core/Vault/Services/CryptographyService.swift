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

    /// A repository to provide the encryption secret key
    ///
    let keychainRepository: KeychainRepository

    // MARK: Initialization

    init(
        keychainRepository: KeychainRepository
    ) {
        self.keychainRepository = keychainRepository
    }

    // MARK: Methods

    func encrypt(_ authenticatorItemView: AuthenticatorItemView) async throws -> AuthenticatorItem {
        let secretKey = try await keychainRepository.getSecretKey(userId: "local")
        guard let totpKeyData = authenticatorItemView.totpKey?.data(using: .utf8),
              let symmetricKey = SymmetricKey(base64EncodedString: secretKey) else {
            throw CryptographyError.unableToParseSecretKey
        }

        let encryptedSealedBox = try AES.GCM.seal(
            totpKeyData,
            using: symmetricKey
        )

        guard let text = encryptedSealedBox.combined?.base64EncodedString() else {
            throw CryptographyError.unableToParseSecretKey
        }

        return AuthenticatorItem(
            id: authenticatorItemView.id,
            name: authenticatorItemView.name,
            totpKey: text
        )
    }

    func decrypt(_ authenticatorItem: AuthenticatorItem) async throws -> AuthenticatorItemView {
        let secretKey = try await keychainRepository.getSecretKey(userId: "local")

        guard let totpKey = authenticatorItem.totpKey,
              let totpKeyData = Data(base64Encoded: totpKey),
              let symmetricKey = SymmetricKey(base64EncodedString: secretKey) else {
            throw CryptographyError.unableToParseSecretKey
        }

        let encryptedSealedBox = try AES.GCM.SealedBox(
            combined: totpKeyData
        )

        let decryptedBox = try AES.GCM.open(
            encryptedSealedBox,
            using: symmetricKey
        )

        return AuthenticatorItemView(
            id: authenticatorItem.id,
            name: authenticatorItem.name,
            totpKey: String(data: decryptedBox, encoding: .utf8)
        )
    }
}

// MARK: - SymmetricKey Extensions

extension SymmetricKey {
    // MARK: Initialization

    /// Creates a `SymmetricKey` from a Base64-encoded `String`.
    ///
    /// - Parameters:
    ///   - base64EncodedString: The Base64-encoded string from which to generate the `SymmetricKey`.
    ///
    init?(base64EncodedString: String) {
        guard let data = Data(base64Encoded: base64EncodedString) else {
            return nil
        }

        self.init(data: data)
    }

    // MARK: Methods

    /// Serializes a `SymmetricKey` to a Base64-encoded `String`.
    func base64EncodedString() -> String {
        return self.withUnsafeBytes { body in
            Data(body).base64EncodedString()
        }
    }
}

// MARK: - CryptographyError

enum CryptographyError: Error {
    case unableToParseSecretKey
}
