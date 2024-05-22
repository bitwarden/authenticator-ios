// MARK: - QrScannerEffect

/// Asynchronous effects that can be processed by a `QrScannerProcessor`.
///
enum QrScannerEffect: Equatable {
    /// The scan view appeared.
    case appeared

    /// The scan view disappeared.
    case disappeared
}
