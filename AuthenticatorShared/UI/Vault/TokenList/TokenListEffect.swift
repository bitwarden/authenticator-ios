// MARK: - TokenListEffect

/// Effects that can be handled by a `TokenListProcessor`.
enum TokenListEffect: Equatable {
    /// The vault group view appeared on screen.
    case appeared

    /// The refresh control was triggered.
    case refresh

    /// Stream the vault list for the user.
    case streamVaultList
}
