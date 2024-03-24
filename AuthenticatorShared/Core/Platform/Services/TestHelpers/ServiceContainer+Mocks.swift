import BitwardenSdk
import Networking

@testable import AuthenticatorShared

extension ServiceContainer {
    static func withMocks(
        application: Application? = nil,
        errorReporter: ErrorReporter = MockErrorReporter(),
        itemRepository: ItemRepository = MockItemRepository(),
        timeProvider: TimeProvider = MockTimeProvider(.currentTime),
        totpService: TOTPService = MockTOTPService()
    ) -> ServiceContainer {
        ServiceContainer(
            application: application,
            errorReporter: errorReporter,
            itemRepository: itemRepository,
            timeProvider: timeProvider,
            totpService: totpService
        )
    }
}
