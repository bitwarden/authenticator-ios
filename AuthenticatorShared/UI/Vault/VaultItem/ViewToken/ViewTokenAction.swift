import BitwardenSdk

// MARK: - ViewTokenAction

/// Synchronous actions that can be processed by a `ViewTokenProcessor`.
enum ViewTokenAction: Equatable {
    /// The toast was shown or hidden.
    case toastShown(Toast?)
}
