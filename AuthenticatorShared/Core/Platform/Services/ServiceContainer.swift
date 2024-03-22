import BitwardenSdk
import UIKit

// swiftlint:disable file_length

/// The `ServiceContainer` contains the list of services used by the app. This can be injected into
/// `Coordinator`s throughout the app which build processors. A `Processor` can define which
/// services it needs access to by defining a typealias containing a list of services.
///
/// For example:
///
///     class ExampleProcessor: StateProcessor<ExampleState, ExampleAction, Void> {
///         typealias Services = HasExampleService
///             & HasExampleRepository
///     }
///
public class ServiceContainer: Services { // swiftlint:disable:this type_body_length
    // MARK: Properties

    /// The application instance (i.e. `UIApplication`), if the app isn't running in an extension.
    let application: Application?

    /// The service used by the application to report non-fatal errors.
    let errorReporter: ErrorReporter

    /// Provides the present time for TOTP Code Calculation.
    let timeProvider: TimeProvider

    // MARK: Initialization

    /// Initialize a `ServiceContainer`.
    ///
    /// - Parameters:
    ///   - application: The application instance.
    ///   - errorReporter: The service used by the application to report non-fatal errors.
    ///   - timeProvider: Provides the present time for TOTP Code Calculation.
    ///
    init(
        application: Application?,
        errorReporter: ErrorReporter,
        timeProvider: TimeProvider
    ) {
        self.application = application
        self.errorReporter = errorReporter
        self.timeProvider = timeProvider
    }

    /// A convenience initializer to initialize the `ServiceContainer` with the default services.
    ///
    /// - Parameters:
    ///   - application: The application instance.
    ///   - errorReporter: The service used by the application to report non-fatal errors.
    ///
    public convenience init(
        application: Application? = nil,
        errorReporter: ErrorReporter
    ) {
        let timeProvider = CurrentTime()

        self.init(
            application: application,
            errorReporter: errorReporter,
            timeProvider: timeProvider
        )
    }
}
