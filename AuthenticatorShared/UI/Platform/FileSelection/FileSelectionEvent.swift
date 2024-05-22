// MARK: - FileSelectionEvent

/// An event to be handled by the FileSelectionCoordinator.
///
enum FileSelectionEvent: Equatable {
    case qrScanFinished(value: ScanResult)
}
