import BitwardenSdk
import SwiftUI

// MARK: - SettingsCoordinatorDelegate

/// An object that is signaled when specific circumstances in the application flow have been encountered.
///
@MainActor
public protocol SettingsCoordinatorDelegate: AnyObject {
    /// Called when the active user's account has been deleted.
    ///
    func didDeleteAccount()

    /// Called when the user has requested an account vault be locked.
    ///
    /// - Parameter userId: The id of the user to lock.
    ///
    func lockVault(userId: String?)

    /// Called when the user has requested an account be logged out.
    ///
    /// - Parameters:
    ///   - userId: The id of the account to log out.
    ///   - userInitiated: Did a user action initiate this logout?
    ///
    func logout(userId: String?, userInitiated: Bool)

    /// Called when the user requests an account switch.
    ///
    /// - Parameters:
    ///   - isUserInitiated: Did the user trigger the account switch?
    ///   - userId: The user Id of the selected account.
    ///
    func switchAccount(isAutomatic: Bool, userId: String)
}

// MARK: - SettingsCoordinator

/// A coordinator that manages navigation in the settings tab.
///
final class SettingsCoordinator: Coordinator, HasStackNavigator {
    // MARK: Types

    /// The module types required by this coordinator for creating child coordinators.
    typealias Module = DefaultAppModule

    typealias Services = HasErrorReporter
        & HasPasteboardService
        & HasStateService
        & HasTimeProvider

    // MARK: Private Properties

    /// The delegate for this coordinator, used to notify when the user logs out.
    private weak var delegate: SettingsCoordinatorDelegate?

    /// The module used to create child coordinators.
    private let module: Module

    /// The services used by this coordinator.
    private let services: Services

    // MARK: Properties

    /// The stack navigator that is managed by this coordinator.
    private(set) weak var stackNavigator: StackNavigator?

    // MARK: Initialization

    /// Creates a new `SettingsCoordinator`.
    ///
    /// - Parameters:
    ///   - delegate: The delegate for this coordinator, used to notify when the user logs out.
    ///   - module: The module used to create child coordinators.
    ///   - services: The services used by this coordinator.
    ///   - stackNavigator: The stack navigator that is managed by this coordinator.
    ///
    init(
        delegate: SettingsCoordinatorDelegate,
        module: Module,
        services: Services,
        stackNavigator: StackNavigator
    ) {
        self.delegate = delegate
        self.module = module
        self.services = services
        self.stackNavigator = stackNavigator
    }

    // MARK: Methods

    func handleEvent(_ event: SettingsEvent, context: AnyObject?) async {
        switch event {
        case let .authAction(action):
            switch action {
            case let .lockVault(userId):
                delegate?.lockVault(userId: userId)
            case let .logout(userId, userInitiated):
                delegate?.logout(userId: userId, userInitiated: userInitiated)
            case let .switchAccount(isAutomatic, userId):
                delegate?.switchAccount(isAutomatic: isAutomatic, userId: userId)
            }
        case .didDeleteAccount:
            stackNavigator?.dismiss {
                self.delegate?.didDeleteAccount()
            }
        }
    }

    func navigate(to route: SettingsRoute, context: AnyObject?) {
        switch route {
        case .about:
            showAbout()
        case .appearance:
            showAppearance()
        case .dismiss:
            stackNavigator?.dismiss()
        case let .selectLanguage(currentLanguage: currentLanguage):
            showSelectLanguage(currentLanguage: currentLanguage, delegate: context as? SelectLanguageDelegate)
        case .settings:
            showSettings()
        }
    }

    func start() {
        navigate(to: .settings)
    }

    // MARK: Private Methods

    /// Shows the about screen.
    ///
    private func showAbout() {
        let processor = AboutProcessor(
            coordinator: asAnyCoordinator(),
            services: services,
            state: AboutState()
        )

        let view = AboutView(store: Store(processor: processor))
        let viewController = UIHostingController(rootView: view)
        viewController.navigationItem.largeTitleDisplayMode = .never
        stackNavigator?.push(viewController, navigationTitle: Localizations.about)
    }

    /// Shows the appearance screen.
    ///
    private func showAppearance() {
        let processor = AppearanceProcessor(
            coordinator: asAnyCoordinator(),
            services: services,
            state: AppearanceState()
        )

        let view = AppearanceView(store: Store(processor: processor))
        let viewController = UIHostingController(rootView: view)
        viewController.navigationItem.largeTitleDisplayMode = .never
        stackNavigator?.push(viewController, navigationTitle: Localizations.appearance)
    }

    /// Shows the select language screen.
    ///
    private func showSelectLanguage(currentLanguage: LanguageOption, delegate: SelectLanguageDelegate?) {
        let processor = SelectLanguageProcessor(
            coordinator: asAnyCoordinator(),
            delegate: delegate,
            services: services,
            state: SelectLanguageState(currentLanguage: currentLanguage)
        )
        let view = SelectLanguageView(store: Store(processor: processor))
        let navController = UINavigationController(rootViewController: UIHostingController(rootView: view))
        stackNavigator?.present(navController)
    }

    /// Shows the settings screen.
    ///
    private func showSettings() {
        let processor = SettingsProcessor(
            coordinator: asAnyCoordinator(),
            state: SettingsState()
        )
        let view = SettingsView(store: Store(processor: processor))
        stackNavigator?.push(view)
    }
}
