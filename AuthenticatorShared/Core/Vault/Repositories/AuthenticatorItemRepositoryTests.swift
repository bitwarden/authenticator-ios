import AuthenticatorBridgeKit
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
    /// from the AuthenticatorItemService. This tests the normal list as-is with the sync flag turned Off (i.e.
    /// no sync'd items from the PM app).
    func test_itemListPublisher_syncFeatureFlagOff() async throws {
        configService.featureFlagsBool[.enablePasswordManagerSync] = false
        sharedItemService.storedItems = ["userId": AuthenticatorBridgeItemDataView.fixtures()]
        sharedItemService.syncOn = true
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

    /// The itemListPublisher should publish the sections of the list based on the items it receives
    /// from the AuthenticatorItemService. This tests the normal list as-is with the sync flag turned On, but
    /// the sync turned off  (i.e. no accounts in the PM app with syncing enabled).
    func test_itemListPublisher_syncOff() async throws {
        configService.featureFlagsBool[.enablePasswordManagerSync] = true
        sharedItemService.storedItems = ["userId": AuthenticatorBridgeItemDataView.fixtures()]
        sharedItemService.syncOn = false
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
        XCTAssertEqual(sections[0].name, favoriteSection.name)
        XCTAssertEqual(sections[1].id, unorganizedSection.id)
        XCTAssertEqual(sections[1].items[0].accountName, unorganizedSection.items[0].accountName)
        XCTAssertEqual(sections[1].items[0].id, unorganizedSection.items[0].id)
        XCTAssertEqual(sections[1].items[0].name, unorganizedSection.items[0].name)
        XCTAssertEqual(sections[1].name, unorganizedSection.name)
    }

    /// The itemListPublisher should publish the sections of the list based on the items it receives
    /// from the AuthenticatorItemService as well as items published by `AuthenticatorBridgeItemService` when
    /// the feature flag is on and sync has been turned on for an account.
    func test_itemListPublisher_withSync() async throws {
        configService.featureFlagsBool[.enablePasswordManagerSync] = true
        sharedItemService.syncOn = true
        let favorite = AuthenticatorItemView.fixture(favorite: true, id: "1", name: "favorite")
        let item = AuthenticatorItemView.fixture()
        let sharedItem = AuthenticatorBridgeItemDataView.fixture(
            name: "Shared",
            totpKey: "totpKey",
            username: "shared@example.com"
        )
        let favoriteSection = ItemListSection(
            id: "Favorites",
            items: [ItemListItem(authenticatorItemView: favorite)!],
            name: Localizations.favorites
        )
        let localSection = ItemListSection(
            id: "LocalCodes",
            items: [ItemListItem(authenticatorItemView: item)!],
            name: Localizations.localCodes
        )
        let sharedSection = ItemListSection(
            id: "BW-shared@example.com",
            items: [ItemListItem(authenticatorItemView: AuthenticatorItemView(item: sharedItem))!],
            name: "shared@example.com"
        )

        try await authenticatorItemService.authenticatorItemsSubject.send([
            cryptographyService.encrypt(item),
            cryptographyService.encrypt(favorite),
        ])
        sharedItemService.sharedItemsSubject.send([
            sharedItem,
        ])

        var sections: [ItemListSection] = []
        for try await value in try await subject.itemListPublisher().prefix(1) {
            sections = value
        }
        XCTAssertEqual(sections[0].id, favoriteSection.id)
        XCTAssertEqual(sections[0].items[0].accountName, favoriteSection.items[0].accountName)
        XCTAssertEqual(sections[0].items[0].id, favoriteSection.items[0].id)
        XCTAssertEqual(sections[0].items[0].name, favoriteSection.items[0].name)
        XCTAssertEqual(sections[0].name, favoriteSection.name)
        XCTAssertEqual(sections[1].id, localSection.id)
        XCTAssertEqual(sections[1].items[0].accountName, localSection.items[0].accountName)
        XCTAssertEqual(sections[1].items[0].id, localSection.items[0].id)
        XCTAssertEqual(sections[1].items[0].name, localSection.items[0].name)
        XCTAssertEqual(sections[1].name, localSection.name)
        XCTAssertEqual(sections[2].id, sharedSection.id)
        XCTAssertEqual(sections[2].items[0].accountName, sharedSection.items[0].accountName)
        XCTAssertEqual(sections[2].items[0].id, sharedSection.items[0].id)
        XCTAssertEqual(sections[2].items[0].name, sharedSection.items[0].name)
        XCTAssertEqual(sections[2].name, sharedSection.name)
    }

    /// When sync is turned on for multiple accounts, the items should be grouped under each account.
    func test_itemListPublisher_withMultipleAccountsSync() async throws {
        configService.featureFlagsBool[.enablePasswordManagerSync] = true
        sharedItemService.syncOn = true
        let favorite = AuthenticatorItemView.fixture(favorite: true, id: "1", name: "favorite")
        let item = AuthenticatorItemView.fixture()
        let firstSharedItem = AuthenticatorBridgeItemDataView.fixture(name: "Shared",
                                                                      totpKey: "totpKey",
                                                                      username: "shared@example.com")
        let otherSharedItem = AuthenticatorBridgeItemDataView.fixture(name: "Shared (Different Account)",
                                                                      totpKey: "totpKey",
                                                                      username: "different@example.com")
        let favoriteSection = ItemListSection(id: "Favorites",
                                              items: [ItemListItem(authenticatorItemView: favorite)!],
                                              name: Localizations.favorites)
        let localSection = ItemListSection(id: "LocalCodes",
                                           items: [ItemListItem(authenticatorItemView: item)!],
                                           name: Localizations.localCodes)
        let sharedSection = ItemListSection(
            id: "BW-shared@example.com",
            items: [ItemListItem(authenticatorItemView: AuthenticatorItemView(item: firstSharedItem))!],
            name: "shared@example.com"
        )
        let otherSharedSection = ItemListSection(
            id: "BW-different@example.com",
            items: [ItemListItem(authenticatorItemView: AuthenticatorItemView(item: otherSharedItem))!],
            name: "different@example.com"
        )

        try await authenticatorItemService.authenticatorItemsSubject.send([
            cryptographyService.encrypt(item),
            cryptographyService.encrypt(favorite),
        ])
        sharedItemService.sharedItemsSubject.send([firstSharedItem, otherSharedItem])

        var sections: [ItemListSection] = []
        for try await value in try await subject.itemListPublisher().prefix(1) {
            sections = value
        }
        XCTAssertEqual(sections[0].id, favoriteSection.id)
        XCTAssertEqual(sections[1].id, localSection.id)
        XCTAssertEqual(sections[2].id, otherSharedSection.id)
        XCTAssertEqual(sections[2].items[0].accountName, otherSharedSection.items[0].accountName)
        XCTAssertEqual(sections[2].items[0].id, otherSharedSection.items[0].id)
        XCTAssertEqual(sections[2].items[0].name, otherSharedSection.items[0].name)
        XCTAssertEqual(sections[2].name, otherSharedSection.name)
        XCTAssertEqual(sections[3].id, sharedSection.id)
        XCTAssertEqual(sections[3].items[0].accountName, sharedSection.items[0].accountName)
        XCTAssertEqual(sections[3].items[0].id, sharedSection.items[0].id)
        XCTAssertEqual(sections[3].items[0].name, sharedSection.items[0].name)
        XCTAssertEqual(sections[3].name, sharedSection.name)
    }
}
