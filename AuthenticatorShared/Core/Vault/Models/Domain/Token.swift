import Foundation

/// Data model for an OTP token
///
public struct Token: Equatable, Sendable {
    // MARK: Properties

    let id: String

    let key: TOTPKey

    let name: String

    // MARK: Initialization

    init?(name: String, authenticatorKey: String) {
        guard let keyType = TOTPKey(authenticatorKey) else { return nil }
        self.id = UUID().uuidString
        self.name = name
        self.key = keyType
    }
}
