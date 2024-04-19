import Foundation

// MARK: - ExportItemsService

/// A service to export a list of items to a file.
///
protocol ExportItemsService: AnyObject {
    /// Removes any temporarily export files.
    func clearTemporaryFiles()

    /// Creates the file contents for exported items of a given file type.
    ///
    /// - Parameters:
    ///   - format: The format to use for export.
    /// - Returns: A string representing the file content.
    ///
    func exportFileContents(format: ExportFileType) async throws -> String

    /// Generates a file name for the export file based on the current date, time, and specified type.
    ///
    /// - Parameters:
    ///   - format: The format type to use to determine the extension.
    /// - Returns: A string representing the file name.
    ///
    func generateExportFileName(format: ExportFileType) -> String

    /// Writes content to file with a provided name and returns a URL for the file.
    ///
    /// - Parameters:
    ///    - fileName: The name of the file.
    ///    - fileContent: The content of the file.
    /// - Returns: A URL for the file.
    ///
    func writeToFile(name fileName: String, content fileContent: String) throws -> URL
}

extension ExportItemsService {
    /// Export items with a given format.
    ///
    /// - Parameters:
    ///   - format: The format of the exported file.
    /// - Returns: A URL for the exported file.
    ///
    func exportItems(format: ExportFileType) async throws -> URL {
        // Export the items in the correct file content format.
        let exportFileContents = try await exportFileContents(format: format)

        // Generate the file name.
        let fileName = generateExportFileName(format: format)

        // Write the content to a file with the name.
        let fileURL = try writeToFile(name: fileName, content: exportFileContents)

        return fileURL
    }
}

class DefaultExportItemsService: ExportItemsService {
    // MARK: Properties

    /// The item service.
    private let authenticatorItemRepository: AuthenticatorItemRepository

    /// The error reporter used by this service.
    private let errorReporter: ErrorReporter

    /// The time provider used by this service.
    private let timeProvider: TimeProvider

    // MARK: Initilzation

    /// Initializes a new instance of a `DefaultExportItemsService`.
    ///
    /// This service handles exporting items from local storage into a file.
    ///
    /// - Parameters:
    ///   - authenticatorItemRepository: The service for getting items.
    ///   - cryptographyService: The service for cryptography tasks.
    ///   - errorReporter: The service for handling errors.
    ///   - timeProvider: The provider for current time, used in file naming and data timestamps.
    ///
    init(
        authenticatorItemRepository: AuthenticatorItemRepository,
        errorReporter: ErrorReporter,
        timeProvider: TimeProvider
    ) {
        self.authenticatorItemRepository = authenticatorItemRepository
        self.errorReporter = errorReporter
        self.timeProvider = timeProvider
    }

    // MARK: Methods

    func clearTemporaryFiles() {
        Task {
            do {
                let url = try FileManager.default.exportedItemsUrl()
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
            } catch {
                errorReporter.log(error: error)
            }
        }
    }

    func generateExportFileName(format: ExportFileType) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = dateFormatter.string(from: timeProvider.presentTime)

        return "bitwarden_authenticator_export_\(dateString).\(format.fileExtension)"
    }

    func exportFileContents(format: ExportFileType) async throws -> String {
        let items = try await authenticatorItemRepository.fetchAllAuthenticatorItems()
        let sortedItems = items.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(sortedItems)
        guard let contents = String(data: data, encoding: .utf8) else {
            throw ExportItemsError.unableToSerializeData
        }
        return contents
    }

    func writeToFile(
        name fileName: String,
        content fileContent: String
    ) throws -> URL {
        // Get the exports directory.
        let exportsDirectoryURL = try FileManager.default.exportedItemsUrl()

        // Check if the directory exists, and create it if it doesn't.
        if !FileManager.default.fileExists(atPath: exportsDirectoryURL.path) {
            try FileManager.default.createDirectory(
                at: exportsDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        // Create the file URL.
        let fileURL = exportsDirectoryURL.appendingPathComponent(fileName, isDirectory: false)

        // Write the content to the file.
        try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}

// MARK: - ExportItemsError

enum ExportItemsError: Error {
    case unableToSerializeData
}
