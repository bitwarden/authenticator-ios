import BitwardenSdk
import SwiftUI

// MARK: - TokenCoordinator

/// A coordinator that manages navigation for displaying, editing, and adding individual tokens.
///
class TokenCoordinator: NSObject, Coordinator, HasStackNavigator {
    // MARK: Types

    typealias Module = TokenModule

    typealias Services = HasErrorReporter

    // MARK: - Private Properties

    /// The module used by this coordinator to create child coordinators.
    private let module: Module

    /// The services used by this coordinator.
    private let services: Services

    // MARK: Properties

    /// The stack navigator that is managed by this coordinator.
    private(set) weak var stackNavigator: StackNavigator?

    // MARK: Initialization

    /// Creates a new `TokenCoordinator`.
    ///
    /// - Parameters:
    ///   - module: The module used by this coordinator to create child coordinators.
    ///   - services: The services used by this coordinator.
    ///   - stackNavigator: The stack navigator that is managed by this coordinator.
    ///
    init(
        module: Module,
        services: Services,
        stackNavigator: StackNavigator
    ) {
        self.module = module
        self.services = services
        self.stackNavigator = stackNavigator
    }

    // MARK: Methods

    func handleEvent(_ event: TokenEvent, context: AnyObject?) async {}

    func navigate(to route: TokenRoute, context: AnyObject?) {}

    func start() {}
}
