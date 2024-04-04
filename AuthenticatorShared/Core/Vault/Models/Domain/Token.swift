import Foundation

/// Data model for an OTP token
///
public struct Token: Sendable {
    // MARK: Properties

    let name: String

    let key: TOTPKey

    // MARK: Initialization

    init?(name: String, authenticatorKey: String) {
        guard let keyType = TOTPKey(authenticatorKey) else { return nil }
        self.name = name
        self.key = keyType
    }
}
