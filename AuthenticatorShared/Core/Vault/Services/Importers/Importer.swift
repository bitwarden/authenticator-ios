import Foundation

// MARK: - Importer

/// A protocol for classes that converts data into items to import.
protocol Importer {
    static func importItems(data: Data) throws -> [AuthenticatorItemView]
}
