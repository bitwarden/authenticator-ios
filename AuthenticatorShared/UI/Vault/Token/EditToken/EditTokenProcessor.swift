import BitwardenSdk
import Foundation

/// The processor used to manage state and handle actions/effects for the edit token screen
final class EditTokenProcessor: StateProcessor<
    EditTokenState,
    EditTokenAction,
    EditTokenEffect
> {
    // MARK: Types

    typealias Services = HasErrorReporter
        & HasTokenRepository

    // MARK: Properties

    /// The `Coordinator` that handles navigation.
    private var coordinator: AnyCoordinator<TokenRoute, TokenEvent>

    /// The services required by this processor.
    private let services: Services

    // MARK: Initialization

    /// Creates a new `EditTokenProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The `Coordinator` that handles navigation.
    ///   - services: The services required by this processor.
    ///   - state: The initial state for the processor.
    ///
    init(
        coordinator: AnyCoordinator<TokenRoute, TokenEvent>,
        services: Services,
        state: EditTokenState
    ) {
        self.coordinator = coordinator
        self.services = services

        super.init(state: state)
    }

    // MARK: Methods

    override func perform(_ effect: EditTokenEffect) async {
        switch effect {
        case .appeared:
            break
        }
    }

    override func receive(_ action: EditTokenAction) {
        switch action {
        case let .nameChanged(newValue):
            state.name = newValue
        }
    }
}
