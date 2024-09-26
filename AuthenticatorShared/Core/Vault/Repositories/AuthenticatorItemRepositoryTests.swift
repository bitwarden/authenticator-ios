import InlineSnapshotTesting
import XCTest

@testable import AuthenticatorShared

class AuthenticatorItemRepositoryTests: AuthenticatorTestCase {
    // MARK: Properties

    var authenticatorItemService: MockAuthenticatorItemService!
    var configService: MockConfigService!
    var cryptographyService: MockCryptographyService!
    var sharedItemService: MockAuthenticatorBridgeItemService!
    var subject: DefaultAuthenticatorItemRepository!

    // MARK: Setup & Teardown

    override func setUp() {
        super.setUp()

        authenticatorItemService = MockAuthenticatorItemService()
        configService = MockConfigService()
        cryptographyService = MockCryptographyService()
        sharedItemService = MockAuthenticatorBridgeItemService()

        subject = DefaultAuthenticatorItemRepository(
            authenticatorItemService: authenticatorItemService,
            configService: configService,
            cryptographyService: cryptographyService,
            sharedItemService: sharedItemService
        )
    }

    override func tearDown() {
        super.tearDown()

        authenticatorItemService = nil
        cryptographyService = nil
        sharedItemService = nil
        subject = nil
    }

    // MARK: Tests

    /// `addAuthenticatorItem()` updates the items in storage
    func test_addAuthenticatorItem() async throws {
        let item = AuthenticatorItemView.fixture()
        try await subject.addAuthenticatorItem(item)

        XCTAssertEqual(cryptographyService.encryptedAuthenticatorItems, [item])
        XCTAssertEqual(
            authenticatorItemService.addAuthenticatorItemAuthenticatorItems.last,
            AuthenticatorItem(authenticatorItemView: item)
        )
    }

    /// `addAuthenticatorItem()` throws an error if encrypting the item fails
    func test_addAuthenticatorItem_encryptError() async {
        cryptographyService.encryptError = AuthenticatorTestError.example

        await assertAsyncThrows(error: AuthenticatorTestError.example) {
            try await subject.addAuthenticatorItem(.fixture())
        }
    }

    /// The itemListPublisher should publish the sections of the list based on the items it receives
    /// from the AuthenticatorItemService.
    func test_itemListPublisher_success() async throws {
        let favorite = AuthenticatorItemView.fixture(favorite: true, id: "1", name: "favorite")
        let item = AuthenticatorItemView.fixture()
        let favoriteSection = ItemListSection(
            id: "Favorites",
            items: [ItemListItem(authenticatorItemView: favorite)!],
            name: Localizations.favorites
        )
        let unorganizedSection = ItemListSection(
            id: "Unorganized",
            items: [ItemListItem(authenticatorItemView: item)!],
            name: ""
        )

        try await authenticatorItemService.authenticatorItemsSubject.send([
            cryptographyService.encrypt(item),
            cryptographyService.encrypt(favorite),
        ])

        var sections: [ItemListSection] = []
        for try await value in try await subject.itemListPublisher().prefix(1) {
            sections = value
        }
        XCTAssertEqual(sections[0].id, favoriteSection.id)
        XCTAssertEqual(sections[0].items[0].accountName, favoriteSection.items[0].accountName)
        XCTAssertEqual(sections[0].items[0].id, favoriteSection.items[0].id)
        XCTAssertEqual(sections[0].items[0].name, favoriteSection.items[0].name)
        XCTAssertEqual(sections[1].id, unorganizedSection.id)
        XCTAssertEqual(sections[1].items[0].accountName, unorganizedSection.items[0].accountName)
        XCTAssertEqual(sections[1].items[0].id, unorganizedSection.items[0].id)
        XCTAssertEqual(sections[1].items[0].name, unorganizedSection.items[0].name)
    }
}
