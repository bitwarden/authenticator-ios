import Foundation

// MARK: - CipherLike

/// A data model used to export/import authenticator items in a way that resembles
/// `Cipher` objects
///
struct CipherLike: Codable, Equatable {
    let id: String
    let name: String
    let folderId: String?
    let organizationId: String?
    let collectionIds: [String]?
    let notes: String?
    let type: Int
    let login: LoginLike
    let favorite: Bool

    init?(_ item: AuthenticatorItemView) {
        guard let login = LoginLike(item) else { return nil }
        id = item.id
        name = item.name
        folderId = nil
        organizationId = nil
        collectionIds = nil
        notes = nil
        type = 1
        favorite = false
        self.login = login
    }
}

// MARK: - LoginLike

/// A data model used to export/import authenticator items in a way that resembles
/// the `Login` part of a `Cipher` object.
///
struct LoginLike: Codable, Equatable {
    let totp: String
    let issuer: String?
    let period: Int
    let digits: Int
    let algorithm: String

    init?(_ item: AuthenticatorItemView) {
        guard let totpKey = item.totpKey,
              let key = TOTPKey(totpKey)
        else { return nil }
        totp = key.base32Key
        issuer = key.issuer
        period = key.period
        digits = key.period
        algorithm = key.algorithm.rawValue
    }
}
