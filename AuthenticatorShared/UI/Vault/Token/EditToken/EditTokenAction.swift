import BitwardenSdk

/// Synchronous actions that can be processed by an `EditItemProcessor`.
enum EditTokenAction: Equatable {
    case nameChanged(String)
}
