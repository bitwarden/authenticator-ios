import BitwardenSdk
import Foundation

// MARK: - ViewTokenProcessor

/// The processor used to manage state and handle actions for the view token screen.
final class ViewTokenProcessor: StateProcessor<
    ViewTokenState,
    ViewTokenAction,
    ViewTokenEffect
> {
    // MARK: Types

    typealias Services = HasErrorReporter
        & HasItemRepository

    // MARK: Properties

    /// The `Coordinator` that handles navigation, typically an `ItemsCoordinator`.
    private let coordinator: AnyCoordinator<ItemsRoute, ItemsEvent>

    /// The ID of the item being viewed.
    private let itemId: String

    /// The services used by this processor.
    private let services: Services

    // MARK: Initialization

    /// Creates a new `ViewTokenProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The `Coordinator` for this processor.
    ///   - itemId: The ID of the item that is being viewed.
    ///   - services: The services used by this processor.
    ///   - state: The initial state of this processor.
    ///
    init(
        coordinator: AnyCoordinator<ItemsRoute, ItemsEvent>,
        itemId: String,
        services: Services,
        state: ViewTokenState
    ) {
        self.coordinator = coordinator
        self.itemId = itemId
        self.services = services
        super.init(state: state)
    }

    // MARK: Methods

    override func perform(_ effect: ViewTokenEffect) async {
        switch effect {
        case .appeared:
            break
        case .totpCodeExpired:
            await updateTOTPCode()
        }
    }

    override func receive(_ action: ViewTokenAction) {
        switch action {
        case let .toastShown(newValue):
            state.toast = newValue
        case .copyPressed(value: let value):
            break
        case .editPressed:
            break
        }
    }
}

private extension ViewTokenProcessor {
    // MARK: Private Methods

    /// Updates the TOTP code for the view.
    func updateTOTPCode() async {}

    /// Stream the cipher details.
    private func streamCipherDetails() async {
        do {
            guard let token = try await services.itemRepository.fetchItem(withId: itemId)
            else { return }

            var totpState = LoginTOTPState(token.login?.totp)
            state.loadingState = .data(TokenItemState(totpState: totpState))

        } catch {
            services.errorReporter.log(error: error)
        }
    }
}
