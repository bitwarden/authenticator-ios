import Foundation

@testable import AuthenticatorShared

class MockImportItemsService: ImportItemsService {
    var importItemsUrl: URL?
    var importItemsFormat: ImportFileType?

    func importItems(url: URL, format: ImportFileType) async throws {
        importItemsUrl = url
        importItemsFormat = format
    }
}
