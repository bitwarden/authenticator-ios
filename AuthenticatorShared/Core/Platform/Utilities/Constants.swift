import Foundation

typealias ClientType = String
typealias DeviceType = Int

// MARK: - Constants

/// Constant values reused throughout the app.
///
enum Constants {
    // MARK: Static Properties

    /// The minimum number of minutes before attempting a server config sync again.
    static let minimumConfigSyncInterval: TimeInterval = 60 * 60 // 60 minutes

    /// The default file name when the file name cannot be determined.
    static let unknownFileName = "unknown_file_name"
}
