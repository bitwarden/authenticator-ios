import XCTest

@testable import AuthenticatorShared

// MARK: - ItemListProcessorTests

class ItemListProcessorTests: AuthenticatorTestCase {
    // MARK: Properties

    var authItemRepository: MockAuthenticatorItemRepository!
    var coordinator: MockCoordinator<ItemListRoute, ItemListEvent>!
    var errorReporter: MockErrorReporter!
    var totpService: MockTOTPService!
    var subject: ItemListProcessor!

    // MARK: Setup & Teardown

    override func setUp() {
        super.setUp()

        authItemRepository = MockAuthenticatorItemRepository()
        coordinator = MockCoordinator()
        errorReporter = MockErrorReporter()
        totpService = MockTOTPService()

        let services = ServiceContainer.withMocks(
            authenticatorItemRepository: authItemRepository,
            errorReporter: errorReporter,
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

    // MARK: Tests

    /// `itemDeleted()` delegate method shows the expected toast.
    func test_delegate_itemDeleted() {
        XCTAssertNil(subject.state.toast)

        subject.itemDeleted()
        XCTAssertEqual(subject.state.toast?.text, Localizations.itemDeleted)
    }

    /// `perform(_:)` with `.appeared` starts streaming vault items.
    func test_perform_appeared() {
        let model = TOTPCodeModel(
            code: "654321",
            codeGenerationDate: Date(year: 2024, month: 6, day: 28),
            period: 30
        )

        let itemListItem = ItemListItem.fixture(
            totp: .fixture(totpCode: model)
        )
        let itemListSection = ItemListSection(id: "", items: [itemListItem], name: "Items")
        authItemRepository.itemListSubject.send([itemListSection])
        totpService.getTotpCodeResult = .success(model)

        let task = Task {
            await subject.perform(.appeared)
        }

        waitFor(subject.state.loadingState != .loading(nil))
        task.cancel()

        XCTAssertEqual(subject.state.loadingState, .data([itemListSection]))
    }

    /// `perform(_:)` with `.appeared` records any errors.
    func test_perform_appeared_error_vaultListGroupSubjectFail() {
        authItemRepository.itemListSubject.send(completion: .failure(AuthenticatorTestError.example))

        let task = Task {
            await subject.perform(.appeared)
        }

        waitFor(!errorReporter.errors.isEmpty)
        task.cancel()

        XCTAssertEqual(errorReporter.errors.last as? AuthenticatorTestError, .example)
    }

    // MARK: AuthenticatorKeyCaptureDelegate Tests

    /// `didCompleteAutomaticCapture` failure
    func test_didCompleteAutomaticCapture_failure() {
        totpService.getTOTPConfigResult = .failure(TOTPServiceError.invalidKeyFormat)
        let captureCoordinator = MockCoordinator<AuthenticatorKeyCaptureRoute, AuthenticatorKeyCaptureEvent>()
        subject.didCompleteAutomaticCapture(captureCoordinator.asAnyCoordinator(), key: "1234")
        var dismissAction: DismissAction?
        if case let .dismiss(onDismiss) = captureCoordinator.routes.last {
            dismissAction = onDismiss
        }
        XCTAssertNotNil(dismissAction)
        dismissAction?.action()
        waitFor(!coordinator.alertShown.isEmpty)
        XCTAssertEqual(
            coordinator.alertShown.last,
            Alert(
                title: Localizations.keyReadError,
                message: nil,
                alertActions: [
                    AlertAction(title: Localizations.ok, style: .default),
                ]
            )
        )
        XCTAssertEqual(authItemRepository.addAuthItemAuthItems, [])
        XCTAssertNil(subject.state.toast)
    }

    /// `didCompleteAutomaticCapture` success
    func test_didCompleteAutomaticCapture_success() throws {
        let key = String.base32Key
        let keyConfig = try XCTUnwrap(TOTPKeyModel(authenticatorKey: key))
        totpService.getTOTPConfigResult = .success(keyConfig)
        authItemRepository.itemListSubject.value = [ItemListSection.fixture()]
        let captureCoordinator = MockCoordinator<AuthenticatorKeyCaptureRoute, AuthenticatorKeyCaptureEvent>()
        subject.didCompleteAutomaticCapture(captureCoordinator.asAnyCoordinator(), key: key)
        var dismissAction: DismissAction?
        if case let .dismiss(onDismiss) = captureCoordinator.routes.last {
            dismissAction = onDismiss
        }
        XCTAssertNotNil(dismissAction)
        dismissAction?.action()
        waitFor(!authItemRepository.addAuthItemAuthItems.isEmpty)
        waitFor(subject.state.loadingState != .loading(nil))
        guard let item = authItemRepository.addAuthItemAuthItems.first
        else {
            XCTFail("Unable to get authenticator item")
            return
        }
        XCTAssertEqual(item.name, "")
        XCTAssertEqual(item.totpKey, String.base32Key)
    }
}
