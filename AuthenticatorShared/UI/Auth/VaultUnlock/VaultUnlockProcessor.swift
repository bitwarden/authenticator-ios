import OSLog

// MARK: - VaultUnlockProcessor

/// The processor used to manage state and handle actions for the unlock screen.
///
class VaultUnlockProcessor: StateProcessor<
    VaultUnlockState,
    VaultUnlockAction,
    VaultUnlockEffect
> {
    // MARK: Types

    typealias Services = HasBiometricsRepository
    & HasErrorReporter

    // MARK: Private Properties

    /// The `Coordinator` that handles navigation.
    private var coordinator: AnyCoordinator<AuthRoute, AuthEvent>

    /// A flag indicating if the processor should attempt automatic biometric unlock
    var shouldAttemptAutomaticBiometricUnlock = true

    /// The services used by this processor.
    private var services: Services

    // MARK: Initialization

    /// Initialize a `VaultUnlockProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator that handles navigation.
    ///   - services: The services used by this processor.
    ///   - state: The initial state of the processor.
    ///
    init(
        coordinator: AnyCoordinator<AuthRoute, AuthEvent>,
        services: Services,
        state: VaultUnlockState
    ) {
        self.coordinator = coordinator
        self.services = services
        super.init(state: state)
    }

    // MARK: Methods

    override func perform(_ effect: VaultUnlockEffect) async {
        switch effect {
        case .appeared:
            await loadData()
        case .unlockWithBiometrics:
            await unlockWithBiometrics()
        }
    }

    override func receive(_ action: VaultUnlockAction) {
        switch action {
        case let .toastShown(toast):
            state.toast = toast
        }
    }

    // MARK: Private Methods

    /// Loads the async state data for the view
    ///
    private func loadData() async {
        state.biometricUnlockStatus = await (try? services.biometricsRepository.getBiometricUnlockStatus())
            ?? .notAvailable
        // If biometric unlock is available, enabled,
        // and the user's biometric integrity state is valid;
        // attempt to unlock the vault with biometrics once.
        if case .available(_, true, true) = state.biometricUnlockStatus,
           shouldAttemptAutomaticBiometricUnlock {
            shouldAttemptAutomaticBiometricUnlock = false
            await unlockWithBiometrics()
        }
    }

    /// Attempts to unlock the vault with the user's biometrics
    ///
    private func unlockWithBiometrics() async {
        let status = try? await services.biometricsRepository.getBiometricUnlockStatus()
        guard case let .available(_, enabled: enabled, hasValidIntegrity) = status,
              enabled,
              hasValidIntegrity else {
            await loadData()
            return
        }

//        do {
//            try await services.authRepository.unlockVaultWithBiometrics()
//            await coordinator.handleEvent(.didCompleteAuth)
//            state.unsuccessfulUnlockAttemptsCount = 0
//            await services.stateService.setUnsuccessfulUnlockAttempts(0)
//        } catch let error as BiometricsServiceError {
//            Logger.processor.error("BiometricsServiceError unlocking vault with biometrics: \(error)")
//            // If the user has locked biometry, logout immediately.
//            if case .biometryLocked = error {
//                await logoutUser(userInitiated: true)
//                return
//            }
//            if case .biometryCancelled = error {
//                // Do nothing if the user cancels.
//                return
//            }
//            // There is no biometric auth key stored, set user preference to false.
//            if case .getAuthKeyFailed = error {
//                try? await services.authRepository.allowBioMetricUnlock(false)
//            }
//            await loadData()
//        } catch let error as StateServiceError {
//            // If there is no active account, don't add to the unsuccessful count.
//            Logger.processor.error("StateServiceError unlocking vault with biometrics: \(error)")
//            // Just send the user back to landing.
//            coordinator.navigate(to: .landing)
//        } catch {
//            Logger.processor.error("Error unlocking vault with biometrics: \(error)")
//            state.unsuccessfulUnlockAttemptsCount += 1
//            await services.stateService
//                .setUnsuccessfulUnlockAttempts(state.unsuccessfulUnlockAttemptsCount)
//            if state.unsuccessfulUnlockAttemptsCount >= 5 {
//                await logoutUser(resetAttempts: true, userInitiated: true)
//                return
//            }
//            await loadData()
//        }
    }
}
