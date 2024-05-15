import XCTest

@testable import AuthenticatorShared

// MARK: - ImportItemsServiceTests

final class ImportItemsServiceTests: AuthenticatorTestCase {
    // MARK: Properties

    var authItemRepository: MockAuthenticatorItemRepository!
    var errorReporter: MockErrorReporter!
    var subject: ImportItemsService!

    // MARK: Setup & Teardown

    override func setUp() {
        super.setUp()

        authItemRepository = MockAuthenticatorItemRepository()
        errorReporter = MockErrorReporter()

        subject = DefaultImportItemsService(
            authenticatorItemRepository: authItemRepository,
            errorReporter: errorReporter
        )
    }

    override func tearDown() {
        super.tearDown()

        authItemRepository = nil
        errorReporter = nil
        subject = nil
    }

    // MARK: Tests

    /// `importItems` can import bitwarden JSON
    func test_importItems_bitwarden() async throws {
        let data = ImportTestData.bitwardenJson.data
        let expected = [
            AuthenticatorItemView(
                favorite: false,
                id: "One",
                name: "Name",
                totpKey: "otpauth://totp/Bitwarden:person@example.com?secret=EXAMPLE&issuer=Bitwarden",
                username: "person@example.com"
            ),
            AuthenticatorItemView(
                favorite: true,
                id: "Two",
                name: "Steam",
                totpKey: "steam://EXAMPLE",
                username: "person@example.com"
            ),
        ]
        try await subject.importItems(data: data, format: .bitwardenJson)
        let actual = authItemRepository.addAuthItemAuthItems
        XCTAssertEqual(actual, expected)
    }

    /// `importItems` can import Raivo JSON
    func test_importItems_raivo() async throws {
        let data = ImportTestData.raivoJson.data
        let expected = [
            AuthenticatorItemView(
                favorite: false,
                id: "One",
                name: "Name",
                totpKey: "otpauth://totp/Bitwarden:person@example.com?secret=EXAMPLE&issuer=Bitwarden",
                username: "person@example.com"
            ),
            AuthenticatorItemView(
                favorite: true,
                id: "Two",
                name: "Steam",
                totpKey: "steam://EXAMPLE",
                username: nil
            ),
        ]
        try await subject.importItems(data: data, format: .bitwardenJson)
        let actual = authItemRepository.addAuthItemAuthItems
        XCTAssertEqual(actual, expected)
    }
}
