import XCTest

@testable import AuthenticatorShared

// swiftlint:disable line_length
final class GoogleImporterTests: AuthenticatorTestCase {
    /// Can import Google protobuf
    func test_googleImport() throws {
        let data = "otpauth-migration://offline?data=ChwKDABEjWzjTY4/7wSo0hIGYW1hem9uIAEoATACEAEYASAAKLvsnOb4/////wE=".data(using: .utf8)!
        let expected = [
            AuthenticatorItemView(
                favorite: false,
                id: "One",
                name: "Name",
                totpKey: "otpauth://totp/Name:person%40example%2Ecom?secret=Secret1One&issuer=Name&algorithm=SHA1&digits=6&period=30",
                username: "person@example.com"
            ),
            AuthenticatorItemView(
                favorite: true,
                id: "Two",
                name: "Issuer2",
                totpKey: "otpauth://totp/?secret=SecretTwo&issuer=Issuer2&algorithm=SHA256&digits=8&period=60",
                username: nil
            ),
        ]
        let actual = try GoogleImporter.importItems(data: data)
        XCTAssertEqual(actual.count, expected.count)
        zip(actual, expected).forEach { actualItem, expectedItem in
            XCTAssertEqual(actualItem.favorite, expectedItem.favorite)
            XCTAssertEqual(actualItem.name, expectedItem.name)
            XCTAssertEqual(actualItem.totpKey, expectedItem.totpKey)
            XCTAssertEqual(actualItem.username, expectedItem.username)
        }
    }
}

// swiftlint:enable line_length
