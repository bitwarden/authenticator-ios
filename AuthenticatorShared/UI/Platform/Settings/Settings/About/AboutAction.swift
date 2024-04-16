// MARK: - AboutAction

/// Actions handled by the `AboutProcessor`.
///
enum AboutAction: Equatable {
    /// Clears the app review URL.
    case clearAppReviewURL

    /// Clears the give feedback URL.
    case clearGiveFeedbackURL

    /// The url has been opened so clear the value in the state.
    case clearURL

    /// The give feedback button was tapped.
    case giveFeedbackTapped

    /// The help center button was tapped.
    case helpCenterTapped

    /// The learn about organizations button was tapped.
    case learnAboutOrganizationsTapped

    /// The privacy policy button was tapped.
    case privacyPolicyTapped

    /// The rate the app button was tapped.
    case rateTheAppTapped

    /// The toast was shown or hidden.
    case toastShown(Toast?)

    /// The submit crash logs toggle value changed.
    case toggleSubmitCrashLogs(Bool)

    /// The tutorial button was tapped
    case tutorialTapped

    /// The version was tapped.
    case versionTapped

    /// The web vault button was tapped.
    case webVaultTapped
}
