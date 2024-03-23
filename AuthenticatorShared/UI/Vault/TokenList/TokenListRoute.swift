import BitwardenSdk
import Foundation

// MARK: - TokenListRoute

/// A route to a specific screen or subscreen of the Token List
public enum TokenListRoute: Equatable, Hashable {
    /// A route to the base token list screen.
    case list
}

enum TokenListEvent {
    case showSomething
}
