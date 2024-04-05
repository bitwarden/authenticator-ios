import BitwardenSdk
import CoreData
import Foundation

/// A data model for persisting tokens
///
class TokenData: NSManagedObject, ManagedObject, CodableModelData {
    typealias Model = CodableTokenKey

    // MARK: Properties

    @NSManaged var id: String

    @NSManaged var name: String

    @NSManaged var modelData: Data?

    // MARK: Initialization

    /// Initialize a `TokenData` object for insertion into the managed object context.
    ///
    /// - Parameters:
    ///   - context: The managed object context to insert the initialized object
    ///   - token: The `Token` object used to create the object
    ///
    convenience init(
        context: NSManagedObjectContext,
        token: Token
    ) throws {
        self.init(context: context)
        id = token.id
        name = token.name
        model = CodableTokenKey(token.key)
    }

    // MARK: Methods

    /// Updates the `TokenData` object from a `Token`
    ///
    /// - Parameters:
    ///   - token: The `Token` object used to update the `TokenData` instance
    ///
    func update(with token: Token) throws {
        id = token.id
        name = token.name
        model = CodableTokenKey(token.key)
    }
}

extension TokenData {
    static func idPredicate(id: String) -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(TokenData.id),
            id
        )
    }
}

struct CodableTokenKey: Codable {
    let keyUri: String

    init(_ key: TOTPKeyModel) {
        keyUri = key.rawAuthenticatorKey
    }
}

extension Token {
    init(tokenData: TokenData) throws {
        guard let keyUri = tokenData.model?.keyUri,
              let key = TOTPKeyModel(authenticatorKey: keyUri)
        else {
            throw DataMappingError.invalidData
        }
        id = tokenData.id
        name = tokenData.name
        self.key = key
    }
}

enum DataMappingError: Error {
    /// Thrown if an object was unable to be constructed because the data was invalid.
    case invalidData

    /// Thrown if a required object identifier is nil.
    case missingId
}
