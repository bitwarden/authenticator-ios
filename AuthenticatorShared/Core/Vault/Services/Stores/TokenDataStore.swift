import BitwardenSdk
import Combine
import CoreData

/// A protocol for a data store that handles data requests for tokens
///
protocol TokenDataStore: AnyObject {
    /// Deletes all `Token` objects
    ///
    func deleteAllTokens() async throws

    /// Deletes a `Token` by ID
    ///
    /// - Parameters:
    ///   - id: the ID of the `Token` to delete
    ///
    func deleteToken(id: String) async throws

    /// Fetches all tokens
    ///
    /// - Returns: The tokens
    ///
    func fetchAllTokens() async throws -> [Token]

    /// Attempts to fetch a token with the given ID
    ///
    /// - Parameters:
    ///   - id: The ID of the `Token` to find
    /// - Returns: The token if it was found and `nil` if not
    ///
    func fetchToken(withId id: String) async throws -> Token?

    /// A publisher for the tokens
    ///
    func tokenPublisher() -> AnyPublisher<[Token], Error>

    /// Replaces a list of `Token` objects
    ///
    /// - Parameters:
    ///   - tokens: The list of tokens to replace existing tokens
    ///
    func replaceTokens(_ tokens: [Token]) async throws

    /// Inserts or updates a token
    ///
    /// - Parameters:
    ///   - tokens: The token to insert or update
    ///
    func upsertToken(_ token: Token) async throws
}

extension DataStore: TokenDataStore {
    func deleteAllTokens() async throws {
        try await executeBatchDelete(TokenData.deleteAllRequest())
    }

    func deleteToken(id: String) async throws {
        try await backgroundContext.performAndSave {
            let results = try self.backgroundContext.fetch(TokenData.fetchByIdRequest(id: id))
            for result in results {
                self.backgroundContext.delete(result)
            }
        }
    }

    func fetchAllTokens() async throws -> [Token] {
        try await backgroundContext.perform {
            let fetchRequest = TokenData.fetchRequest()
            return try self.backgroundContext.fetch(fetchRequest).map(Token.init)
        }
    }

    func fetchToken(withId id: String) async throws -> Token? {
        try await backgroundContext.perform {
            try self.backgroundContext.fetch(TokenData.fetchByIdRequest(id: id))
                .compactMap(Token.init)
                .first
        }
    }

    func replaceTokens(_ tokens: [Token]) async throws {
        let deleteRequest = TokenData.deleteAllRequest()
        let insertRequest = try TokenData.batchInsertRequest(objects: tokens) { token, value in
            try token.update(with: value)
        }
        try await executeBatchReplace(
            deleteRequest: deleteRequest,
            insertRequest: insertRequest
        )
    }

    func tokenPublisher() -> AnyPublisher<[Token], Error> {
        let fetchRequest = TokenData.fetchRequest()
        // A sort descriptor is needed by `NSFetchedResultsController`
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TokenData.id, ascending: true)]
        return FetchedResultsPublisher(
            context: persistentContainer.viewContext,
            request: fetchRequest
        )
        .tryMap { try $0.map(Token.init) }
        .eraseToAnyPublisher()
    }

    func upsertToken(_ token: Token) async throws {
        try await backgroundContext.performAndSave {
            _ = try TokenData(context: self.backgroundContext, token: token)
        }
    }
}
