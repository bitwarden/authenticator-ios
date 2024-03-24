import BitwardenSdk
import Combine
import Foundation
import OSLog

/// A protocol for an `ItemRepository` which manages acess to the data needed by the UI layer.
///
public protocol ItemRepository: AnyObject {
    // MARK: Data Methods

    func addItem(_ item: CipherView) async throws

    func deleteItem(_ id: String)

    func fetchItem(withId id: String) async throws -> CipherView?

    /// Regenerates the TOTP code for a given key.
    ///
    /// - Parameter key: The key for a TOTP code.
    /// - Returns: An updated LoginTOTPState.
    ///
    func refreshTOTPCode(for key: TOTPKeyModel) async throws -> LoginTOTPState

    /// Regenerates the TOTP codes for a list of Vault Items.
    ///
    /// - Parameter items: The list of items that need updated TOTP codes.
    /// - Returns: An updated list of items with new TOTP codes.
    ///
    func refreshTOTPCodes(for items: [VaultListItem]) async throws -> [VaultListItem]

    func updateItem(_ item: CipherView) async throws

    // MARK: Publishers

    func vaultListPublisher() async throws -> AsyncThrowingPublisher<AnyPublisher<[VaultListItem], Never>>
}

class DefaultItemRepository {

}

extension DefaultItemRepository: ItemRepository {
    // MARK: Data Methods

    func addItem(_ item: BitwardenSdk.CipherView) async throws {}
    
    func deleteItem(_ id: String) {}
    
    func fetchItem(withId id: String) async throws -> BitwardenSdk.CipherView? {
        return nil
    }
    
    func refreshTOTPCode(for key: TOTPKeyModel) async throws -> LoginTOTPState {
        return .none
    }
    
    func refreshTOTPCodes(for items: [VaultListItem]) async throws -> [VaultListItem] {
//        await items.asyncMap { item in
//            guard case let .totp(name, model) = item.itemType,
//                  let key = model.loginView.totp,
//                  let code = try? await cl
//
//        }
//        .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
//
//
        return items
    }
    
    func updateItem(_ item: BitwardenSdk.CipherView) async throws {}
    
    // MARK: Publishers

    func vaultListPublisher() async throws -> AsyncThrowingPublisher<AnyPublisher<[VaultListItem], Never>> {
//        try await Publishers.
        Just([
            VaultListItem(
                cipherView: .init(
                    id: UUID().uuidString,
                    organizationId: nil,
                    folderId: nil,
                    collectionIds: [],
                    key: nil,
                    name: "Test",
                    notes: nil,
                    type: .login,
                    login: .init(
                        username: "Username",
                        password: "Password",
                        passwordRevisionDate: nil,
                        uris: nil,
                        totp: "asdf",
                        autofillOnPageLoad: false,
                        fido2Credentials: nil
                    ),
                    identity: nil,
                    card: nil,
                    secureNote: nil,
                    favorite: false,
                    reprompt: .none,
                    organizationUseTotp: false,
                    edit: false,
                    viewPassword: false,
                    localData: nil,
                    attachments: nil,
                    fields: nil,
                    passwordHistory: nil,
                    creationDate: Date(timeIntervalSinceNow: -1440),
                    deletedDate: nil,
                    revisionDate: Date(timeIntervalSinceNow: -1440)
                )
            )!,
            VaultListItem(
                id: UUID().uuidString,
                itemType: .totp(
                    name: "Name",
                    totpModel: VaultListTOTP(
                        id: UUID().uuidString,
                        loginView: .init(
                            username: "Username",
                            password: "Password",
                            passwordRevisionDate: nil,
                            uris: nil,
                            totp: "asdf",
                            autofillOnPageLoad: false,
                            fido2Credentials: nil
                        ),
                        totpCode: TOTPCodeModel(
                            code: "123456",
                            codeGenerationDate: Date(),
                            period: 30
                        )
                    )
                )
            ),
        ])
        .eraseToAnyPublisher()
        .values
    }
}
