import AuthenticatorBridgeKit
import Combine
import Foundation

// MARK: - AuthenticatorItemRepository

/// A protocol for an `AuthenticatorItemRepository` which manages access to the data layer for items
///
protocol AuthenticatorItemRepository: AnyObject {
    // MARK: Data Methods

    /// Adds an item to the user's storage
    ///
    /// - Parameters:
    ///   - authenticatorItem: The item to add
    ///
    func addAuthenticatorItem(_ authenticatorItem: AuthenticatorItemView) async throws

    /// Deletes an item from the user's storage
    ///
    /// - Parameters:
    ///   - id: The item ID to delete
    ///
    func deleteAuthenticatorItem(_ id: String) async throws

    /// Attempt to fetch an item with the given ID
    ///
    /// - Parameters:
    ///   - id: The ID of the item to find
    /// - Returns: The item if found and `nil` if not
    ///
    func fetchAuthenticatorItem(withId id: String) async throws -> AuthenticatorItemView?

    /// Fetch all items
    ///
    /// Returns: An array of all items in storage
    ///
    func fetchAllAuthenticatorItems() async throws -> [AuthenticatorItemView]

    /// Regenerates the TOTP codes for a list of items.
    ///
    /// - Parameters:
    ///   - items: The list of items that need updated TOTP codes.
    /// - Returns: A list of items with updated TOTP codes.
    ///
    func refreshTotpCodes(on items: [ItemListItem]) async throws -> [ItemListItem]

    /// Updates an item in the user's storage
    ///
    /// - Parameters:
    ///   - authenticatorItem: The updated item
    ///
    func updateAuthenticatorItem(_ authenticatorItem: AuthenticatorItemView) async throws

    // MARK: Publishers

    /// A publisher for the details of an item
    ///
    /// - Parameters:
    ///   - id: The ID of the item that should be published
    /// - Returns: A publisher for the details of the item,
    ///            which will be notified as details of the item change
    ///
    func authenticatorItemDetailsPublisher(
        id: String
    ) async throws -> AsyncThrowingPublisher<AnyPublisher<AuthenticatorItemView?, Error>>

    /// A publisher for the list of a user's items, which returns a list of sections
    /// of items that are displayed
    ///
    /// - Returns: A publisher for the list of a user's items
    ///
    func itemListPublisher() async throws -> AsyncThrowingPublisher<AnyPublisher<[ItemListSection], Error>>

    /// A publisher for searching a user's cipher objects based on the specified search text and filter type.
    ///
    /// - Parameters:
    ///   - searchText: The search text to filter the cipher list.
    /// - Returns: A publisher searching for the user's ciphers.
    ///
    func searchItemListPublisher(
        searchText: String
    ) async throws -> AsyncThrowingPublisher<AnyPublisher<[ItemListItem], Error>>
}

// MARK: - DefaultAuthenticatorItemRepository

/// A default implementation of an `AuthenticatorItemRepository`
///
class DefaultAuthenticatorItemRepository {
    // MARK: Properties

    /// Service to from which to fetch locally stored Authenticator items.
    private let authenticatorItemService: AuthenticatorItemService

    /// Service to determine if the sync feature flag is turned on.
    private let configService: ConfigService

    /// Service to encrypt/decrypt locally stored Authenticator items.
    private let cryptographyService: CryptographyService

    /// Error Reporter for any errors encountered
    private let errorReporter: ErrorReporter

    /// Service to fetch items from the shared CoreData store - shared from the main Bitwarden PM app.
    private let sharedItemService: AuthenticatorBridgeItemService

    /// A protocol wrapping the present time.
    private let timeProvider: TimeProvider

    /// A service for refreshing TOTP codes.
    private let totpService: TOTPService

    // MARK: Initialization

    /// Initialize a `DefaultAuthenticatorItemRepository`
    ///
    /// - Parameters:
    ///   - authenticatorItemService: Service to from which to fetch locally stored Authenticator items.
    ///   - configService: Service to determine if the sync feature flag is turned on.
    ///   - cryptographyService: Service to encrypt/decrypt locally stored Authenticator items.
    ///   - sharedItemService: Service to fetch items from the shared CoreData store - shared from
    ///     the main Bitwarden PM app.
    ///   - errorReporter: Error Reporter for any errors encountered
    ///   - timeProvider: A protocol wrapping the present time.
    ///   - totpService: A service for refreshing TOTP codes.
    init(
        authenticatorItemService: AuthenticatorItemService,
        configService: ConfigService,
        cryptographyService: CryptographyService,
        errorReporter: ErrorReporter,
        sharedItemService: AuthenticatorBridgeItemService,
        timeProvider: TimeProvider,
        totpService: TOTPService
    ) {
        self.authenticatorItemService = authenticatorItemService
        self.configService = configService
        self.cryptographyService = cryptographyService
        self.errorReporter = errorReporter
        self.timeProvider = timeProvider
        self.totpService = totpService
        self.sharedItemService = sharedItemService
    }

    // MARK: Private Methods

    /// Returns a list of the sections in the item list
    ///
    /// - Parameters:
    ///   - authenticatorItems: The items in the user's storage
    /// - Returns: A list of the sections to display in the item list
    ///
    private func itemListSections(
        from authenticatorItems: [AuthenticatorItem]
    ) async throws -> [ItemListSection] {
        let items = try await authenticatorItems.asyncMap { item in
            try await self.cryptographyService.decrypt(item)
        }
        .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        let favorites = items.filter(\.favorite).compactMap { item in
            ItemListItem(authenticatorItemView: item, timeProvider: self.timeProvider)
        }
        let nonFavorites = items.filter { !$0.favorite }.compactMap { item in
            ItemListItem(authenticatorItemView: item, timeProvider: self.timeProvider)
        }

        let syncEnabled: Bool = await configService.getFeatureFlag(.enablePasswordManagerSync)
        let syncOn = await sharedItemService.isSyncOn()
        let useSyncValues = syncEnabled && syncOn

        return [
            ItemListSection(id: "Favorites", items: favorites, name: Localizations.favorites),
            ItemListSection(id: useSyncValues ? "LocalCodes" : "Unorganized",
                            items: nonFavorites,
                            name: useSyncValues ? Localizations.localCodes : ""),
        ]
        .filter { !$0.items.isEmpty }
    }

    /// Appends a list of the sections to the item list when sync with the PM app is enabled.
    ///
    /// Note: If the `enablePasswordManagerSync` feature flag is turned off, or if the user has not yet
    /// turned on sync for any accounts, this method simply returns `localSections`.
    ///
    /// - Parameters:
    ///   - localSections: The [ItemListSection] sections for the items locally stored
    ///   - sharedItems: The shared items that are coming in via sync with the PM app
    /// - Returns: A list of the sections to display in the item list
    ///
    private func appendSyncedItems(
        localSections: [ItemListSection],
        sharedItems: [AuthenticatorBridgeItemDataView]
    ) async throws -> [ItemListSection] {
        guard await configService.getFeatureFlag(.enablePasswordManagerSync),
              await sharedItemService.isSyncOn() else {
            return localSections
        }

        let sharedItems = sharedItems.map(AuthenticatorItemView.init)
        let groupsByUsername = Dictionary(grouping: sharedItems, by: { $0.username })

        var sections = localSections

        let keys = groupsByUsername.keys.compactMap { $0 }
        for key in keys.sorted() {
            let items = groupsByUsername[key]?.compactMap { item in
                ItemListItem(authenticatorItemView: item, timeProvider: self.timeProvider)
            } ?? []

            sections.append(ItemListSection(id: "BW-\(key)", items: items, name: key))
        }

        return sections.filter { !$0.items.isEmpty }
    }

    /// A publisher for searching a user's items based on the specified search text and filter type.
    ///
    /// - Parameters:
    ///   - searchText: The search text to filter the item list.
    /// - Returns: A publisher searching for the user's ciphers.
    ///
    private func searchPublisher(
        searchText: String
    ) async throws -> AnyPublisher<[AuthenticatorItemView], Error> {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)

        return try await authenticatorItemService.authenticatorItemsPublisher()
            .asyncTryMap { items -> [AuthenticatorItemView] in
                let matchingItems = try await items.asyncMap { item in
                    try await self.cryptographyService.decrypt(item)
                }

                var matchedItems: [AuthenticatorItemView] = []

                matchingItems.forEach { item in
                    if item.name.lowercased()
                        .folding(options: .diacriticInsensitive, locale: nil)
                        .contains(query) {
                        matchedItems.append(item)
                    }
                }

                return matchedItems.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            }.eraseToAnyPublisher()
    }
}

extension DefaultAuthenticatorItemRepository: AuthenticatorItemRepository {
    // MARK: Data Methods

    func addAuthenticatorItem(_ authenticatorItem: AuthenticatorItemView) async throws {
        let item = try await cryptographyService.encrypt(authenticatorItem)
        try await authenticatorItemService.addAuthenticatorItem(item)
    }

    func deleteAuthenticatorItem(_ id: String) async throws {
        try await authenticatorItemService.deleteAuthenticatorItem(id: id)
    }

    func fetchAllAuthenticatorItems() async throws -> [AuthenticatorItemView] {
        let items = try await authenticatorItemService.fetchAllAuthenticatorItems()
        return try await items.asyncMap { item in
            try await cryptographyService.decrypt(item)
        }
    }

    func fetchAuthenticatorItem(withId id: String) async throws -> AuthenticatorItemView? {
        guard let item = try await authenticatorItemService.fetchAuthenticatorItem(withId: id) else { return nil }
        return try? await cryptographyService.decrypt(item)
    }

    func refreshTotpCodes(on items: [ItemListItem]) async throws -> [ItemListItem] {
        try await items.asyncMap { item in
            guard case let .totp(model) = item.itemType,
                  let key = model.itemView.totpKey,
                  let keyModel = TOTPKeyModel(authenticatorKey: key)
            else {
                errorReporter.log(error: TOTPServiceError
                    .unableToGenerateCode("Unable to refresh TOTP code for list view item: \(item.id)"))
                return item
            }
            let code = try await totpService.getTotpCode(for: keyModel)
            var updatedModel = model
            updatedModel.totpCode = code
            return ItemListItem(
                id: item.id,
                name: item.name,
                accountName: item.accountName,
                itemType: .totp(model: updatedModel)
            )
        }
    }

    func updateAuthenticatorItem(_ authenticatorItem: AuthenticatorItemView) async throws {
        let item = try await cryptographyService.encrypt(authenticatorItem)
        try await authenticatorItemService.updateAuthenticatorItem(item)
    }

    // MARK: Publishers

    func authenticatorItemDetailsPublisher(
        id: String
    ) async throws -> AsyncThrowingPublisher<AnyPublisher<AuthenticatorItemView?, Error>> {
        try await authenticatorItemService.authenticatorItemsPublisher()
            .asyncTryMap { items -> AuthenticatorItemView? in
                guard let item = items.first(where: { $0.id == id }) else { return nil }
                return try await self.cryptographyService.decrypt(item)
            }
            .eraseToAnyPublisher()
            .values
    }

    func itemListPublisher() async throws -> AsyncThrowingPublisher<AnyPublisher<[ItemListSection], Error>> {
        try await authenticatorItemService.authenticatorItemsPublisher()
            .combineLatest(
                sharedItemService.sharedItemsPublisher()
            )
            .asyncTryMap { items in
                let sections = try await self.itemListSections(from: items.0)
                return try await self.appendSyncedItems(localSections: sections, sharedItems: items.1)
            }
            .eraseToAnyPublisher()
            .values
    }

    func searchItemListPublisher(
        searchText: String
    ) async throws -> AsyncThrowingPublisher<AnyPublisher<[ItemListItem], Error>> {
        try await searchPublisher(
            searchText: searchText
        ).asyncTryMap { items in
            items.compactMap { item in
                ItemListItem(authenticatorItemView: item, timeProvider: self.timeProvider)
            }
        }
        .eraseToAnyPublisher()
        .values
    }
}
