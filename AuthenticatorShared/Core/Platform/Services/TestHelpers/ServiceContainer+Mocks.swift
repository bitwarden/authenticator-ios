import BitwardenSdk
import Networking

@testable import AuthenticatorShared

extension ServiceContainer {
    static func withMocks(
        application: Application? = nil,
        errorReporter: ErrorReporter = MockErrorReporter(),
        timeProvider: TimeProvider = MockTimeProvider(.currentTime)
    ) -> ServiceContainer {
        ServiceContainer(
            application: application,
            errorReporter: errorReporter,
            timeProvider: timeProvider
        )
    }
}
