// MARK: - TutorialProcessor

/// The processer used to manage state and handle actions for the tutorial screen.
///
final class TutorialProcessor: StateProcessor<TutorialState, TutorialAction, TutorialEvent> {
    // MARK: Types

    typealias Services = HasErrorReporter

    // MARK: Private Properties

    /// The `Coordinator` that handles navigation, generally a `TutorialCoordinator`.
    private let coordinator: AnyCoordinator<TutorialRoute, TutorialEvent>

    // MARK: Initialization

    /// Creates a new `TutorialProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The `Coordinator` that handles navigation.
    ///   - state: The initial state of the processor.
    ///
    init(
        coordinator: AnyCoordinator<TutorialRoute, TutorialEvent>,
        state: TutorialState
    ) {
        self.coordinator = coordinator
        super.init(state: state)
    }

    // MARK: Methods

    override func receive(_ action: TutorialAction) {}
}
