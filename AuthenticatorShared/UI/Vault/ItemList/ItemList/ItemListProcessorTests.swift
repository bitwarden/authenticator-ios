import XCTest

@testable import AuthenticatorShared

// MARK: - ItemListProcessorTests

class ItemListProcessorTests: AuthenticatorTestCase {
    // MARK: Properties

    var authItemRepository: MockAuthenticatorItemRepository!
    var coordinator: MockCoordinator<ItemListRoute, ItemListEvent>!
    var totpService: MockTOTPService!
    var subject: ItemListProcessor!

    // MARK: Setup & Teardown

    override func setUp() {
        super.setUp()

        authItemRepository = MockAuthenticatorItemRepository()
        coordinator = MockCoordinator()
        totpService = MockTOTPService()

        let services = ServiceContainer.withMocks(
            authenticatorItemRepository: authItemRepository,
            totpService: totpService
        )

        subject = ItemListProcessor(
            coordinator: coordinator.asAnyCoordinator(),
            services: services,
            state: ItemListState()
        )
    }

    override func tearDown() {
        super.tearDown()

        coordinator = nil
        subject = nil
    }

    /// `didCompleteCapture` with a value updates the state with the new auth key value
    /// and navigates to the `.dismiss` route.
    func test_didCompleteCapture_failure() {
        totpService.getTOTPConfigResult = .failure(TOTPServiceError.invalidKeyFormat)
        let captureCoordinator = MockCoordinator<AuthenticatorKeyCaptureRoute, AuthenticatorKeyCaptureEvent>()
        subject.didCompleteCapture(captureCoordinator.asAnyCoordinator(), key: "1234", name: nil)
        var dismissAction: DismissAction?
        if case let .dismiss(onDismiss) = captureCoordinator.routes.last {
            dismissAction = onDismiss
        }
        XCTAssertNotNil(dismissAction)
        dismissAction?.action()
        XCTAssertEqual(
            coordinator.alertShown.last,
            Alert(
                title: Localizations.authenticatorKeyReadError,
                message: nil,
                alertActions: [
                    AlertAction(title: Localizations.ok, style: .default),
                ]
            )
        )
        XCTAssertEqual(authItemRepository.addAuthItemAuthItems, [])
        XCTAssertNil(subject.state.toast)
    }

    /// `didCompleteCapture` with a value updates the state with the new auth key value
    /// and navigates to the `.dismiss()` route.
    func test_didCompleteCapture_success() throws {
        let key = String.base32Key
        let keyConfig = try XCTUnwrap(TOTPKeyModel(authenticatorKey: key))
        totpService.getTOTPConfigResult = .success(keyConfig)
        let captureCoordinator = MockCoordinator<AuthenticatorKeyCaptureRoute, AuthenticatorKeyCaptureEvent>()
        subject.didCompleteCapture(captureCoordinator.asAnyCoordinator(), key: key, name: nil)
        var dismissAction: DismissAction?
        if case let .dismiss(onDismiss) = captureCoordinator.routes.last {
            dismissAction = onDismiss
        }
        XCTAssertNotNil(dismissAction)
        dismissAction?.action()
        guard let item = authItemRepository.addAuthItemAuthItems.first
        else {
            XCTFail("Unable to get authenticator item")
            return
        }
        XCTAssertEqual(item.name, "")
        XCTAssertEqual(item.totpKey, String.base32Key)
        XCTAssertEqual(subject.state.toast?.text, Localizations.authenticatorKeyAdded)
    }
}
