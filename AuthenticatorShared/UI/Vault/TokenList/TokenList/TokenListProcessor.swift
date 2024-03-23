import BitwardenSdk
import Foundation

// MARK: - TokenListProcessor

/// A `Processor` that can process `TokenListAction`s and `TokenListEffect`s.
final class TokenListProcessor: StateProcessor<TokenListState, TokenListAction, TokenListEffect> {
    // MARK: Types

    typealias Services = HasTimeProvider

    // MARK: Private Properties

    /// The `Coordinator` for this processor.
    private var coordinator: any Coordinator<TokenListRoute, TokenListEvent>

    /// The services for this processor.
    private var services: Services

    // MARK: Initialization

    /// Creates a new `TokenListProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The `Coordinator` for this processor.
    ///   - services: The services for this processor.
    ///   - state: The initial state of this processor.
    ///
    init(
        coordinator: any Coordinator<TokenListRoute, TokenListEvent>,
        services: Services,
        state: TokenListState
    ) {
        self.coordinator = coordinator
        self.services = services

        super.init(state: state)
    }

    // MARK: Methods

    override func perform(_ effect: TokenListEffect) async {}

    override func receive(_ action: TokenListAction) {}
}
