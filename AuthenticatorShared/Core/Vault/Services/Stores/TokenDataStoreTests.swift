import CoreData
import XCTest

@testable import AuthenticatorShared

class TokenDataStoreTests: AuthenticatorTestCase {
    // MARK: Properties

    var subject: DataStore!

    let tokens: [Token] = [
        Token(id: "1", name: "One", authenticatorKey: "exampleone")!,
        Token(id: "2", name: "Two", authenticatorKey: "exampletwo")!,
        Token(id: "3", name: "Three", authenticatorKey: "examplethree")!,
    ]

    // MARK: Setup & Teardown

    override func setUp() {
        super.setUp()

        subject = DataStore(errorReporter: MockErrorReporter(), storeType: .memory)
    }

    override func tearDown() {
        super.tearDown()

        subject = nil
    }

    /// `deleteAllTokens()` removes all tokens
    func test_deleteAllTokens() async throws {
        try await insertTokens(tokens)

        try await subject.deleteAllTokens()

        try XCTAssertTrue(fetchTokens().isEmpty)
    }

    /// `deleteToken(id:)` removes the token with the given ID
    func test_deleteToken() async throws {
        try await insertTokens(tokens)

        try await subject.deleteToken(id: "2")

        try XCTAssertEqual(
            fetchTokens(),
            tokens.filter { $0.id != "2" }
        )
    }

    /// `fetchAllTokens()` returns all the tokens
    func test_fetchAllTokens() async throws {
        try await insertTokens(tokens)

        let actualTokens = try await subject.fetchAllTokens().sorted { $0.id < $1.id }
        let expectedTokens = tokens.sorted { $0.id < $1.id }
        XCTAssertEqual(actualTokens, expectedTokens)
    }

    /// `fetchToken(withId:)` returns the specified token if it exists and `nil` otherwise
    func test_fetchToken() async throws {
        try await insertTokens(tokens)

        let token1 = try await subject.fetchToken(withId: "1")
        XCTAssertEqual(token1, tokens.first)

        let token42 = try await subject.fetchToken(withId: "42")
        XCTAssertNil(token42)
    }

    /// `replaceTokens(_:)` replaces the list of tokens
    func test_replaceTokens() async throws {
        try await insertTokens(tokens)

        let newTokens = [
            Token(id: "3", name: "Three", authenticatorKey: "examplethree")!,
            Token(id: "4", name: "Four", authenticatorKey: "examplefour")!,
            Token(id: "5", name: "Five", authenticatorKey: "examplefive")!,
        ]
        try await subject.replaceTokens(newTokens)

        XCTAssertEqual(try fetchTokens(), newTokens)
    }

    /// `tokenPublisher()` returns a publisher for token objects
    func test_tokenPublisher() async throws {
        var publishedValues = [[Token]]()
        let publisher = subject.tokenPublisher()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { values in
                    publishedValues.append(values)
                }
            )
        defer { publisher.cancel() }

        try await subject.replaceTokens(tokens)

        waitFor { publishedValues.count == 2 }
        XCTAssertTrue(publishedValues[0].isEmpty)
        XCTAssertEqual(publishedValues[1], tokens)
    }

    /// `upsertToken(_:)` inserts a token
    func test_upsertToken_insert() async throws {
        let token1 = Token(id: "1", name: "One", authenticatorKey: "exampleone")!
        try await subject.upsertToken(token1)

        try XCTAssertEqual(fetchTokens(), [token1])

        let token2 = Token(id: "2", name: "Two", authenticatorKey: "exampletwo")!
        try await subject.upsertToken(token2)

        try XCTAssertEqual(fetchTokens(), [token1, token2])
    }

    /// `upsertToken(_:)` updates an existing token
    func test_upsertToken_update() async throws {
        try await insertTokens(tokens)

        let updatedToken = Token(id: "2", name: "Two", authenticatorKey: "updated")!
        try await subject.upsertToken(updatedToken)

        var expectedTokens = tokens
        expectedTokens[1] = updatedToken

        try XCTAssertEqual(fetchTokens(), expectedTokens)
    }

    // MARK: Test Helpers

    /// A test helper to fetch all tokens
    private func fetchTokens() throws -> [Token] {
        let fetchRequest: NSFetchRequest<TokenData> = TokenData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TokenData.id, ascending: true)]
        return try subject.backgroundContext.fetch(fetchRequest).map(Token.init)
    }

    /// A test helper for inserting a list of tokens for a user
    private func insertTokens(_ tokens: [Token]) async throws {
        try await subject.backgroundContext.performAndSave {
            for token in tokens {
                _ = try TokenData(context: self.subject.backgroundContext, token: token)
            }
        }
    }
}
