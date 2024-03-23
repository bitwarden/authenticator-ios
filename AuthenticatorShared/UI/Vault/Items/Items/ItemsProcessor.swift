import BitwardenSdk
import Foundation

// MARK: - ItemsProcessor

/// A `Processor` that can process `ItemsAction`s and `ItemsEffect`s.
final class ItemsProcessor: StateProcessor<ItemsState, ItemsAction, ItemsEffect> {
    // MARK: Types

    typealias Services = HasTimeProvider

    // MARK: Private Properties

    /// The `Coordinator` for this processor.
    private var coordinator: any Coordinator<ItemsRoute, ItemsEvent>

    /// The services for this processor.
    private var services: Services

    // MARK: Initialization

    /// Creates a new `ItemsProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The `Coordinator` for this processor.
    ///   - services: The services for this processor.
    ///   - state: The initial state of this processor.
    ///
    init(
        coordinator: any Coordinator<ItemsRoute, ItemsEvent>,
        services: Services,
        state: ItemsState
    ) {
        self.coordinator = coordinator
        self.services = services

        super.init(state: state)
    }

    // MARK: Methods

    override func perform(_ effect: ItemsEffect) async {}

    override func receive(_ action: ItemsAction) {}
}
