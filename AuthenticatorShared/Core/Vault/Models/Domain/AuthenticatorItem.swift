import Foundation

/// Data model for an encrypted item
///
struct AuthenticatorItem: Equatable, Sendable {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    init(itemData: AuthenticatorItemData) throws {
        guard let model = itemData.model else {
            throw DataMappingError.invalidData
        }
        id = model.id
        name = model.name
    }
}

extension AuthenticatorItem {
    static func fixture(
        id: String = "ID",
        name: String = "Example"
    ) -> AuthenticatorItem {
        AuthenticatorItem(
            id: id,
            name: name
        )
    }
}

/// Data model for an unencrypted item
///
struct AuthenticatorItemView: Equatable, Sendable {
    let id: String
    let name: String
}

extension AuthenticatorItemView {
    static func fixture(
        id: String = "ID",
        name: String = "Example"
    ) -> AuthenticatorItemView {
        AuthenticatorItemView(
            id: id,
            name: name
        )
    }
}
