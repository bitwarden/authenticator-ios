import BitwardenSdk

/// The services provided by the `ServiceContainer`.
typealias Services = HasTOTPService
    & HasTimeProvider

/// Protocol for an object that provides a `TOTPService`.
///
protocol HasTOTPService {
    /// A service used to validate authentication keys and generate TOTP codes.
    var totpService: TOTPService { get }
}

/// Protocol for an object that provides a `TimeProvider`.
///
protocol HasTimeProvider {
    /// Provides the present time for TOTP Code Calculation.
    var timeProvider: TimeProvider { get }
}
