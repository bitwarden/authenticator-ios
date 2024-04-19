// MARK: - ExportItemsAction

/// Synchronous actions handled by an `ExportItemsProcessor`.
enum ExportItemsAction: Equatable {
    /// Dismiss the sheet.
    case dismiss

    /// The export button was tapped.
    case exportTapped
}
