import Combine
import OSLog
import SwiftUI

// MARK: - QrScannerProcessor

/// A processor for the QR Scanner screen. This screen handles scanning general QR codes.
///
final class QrScannerProcessor: StateProcessor<QrScannerState, QrScannerAction, QrScannerEffect> {
    // MARK: Types

    /// Required services.
    typealias Services = HasCameraService
        & HasErrorReporter

    // MARK: Properties

    /// A publisher that publishes the processor's scan result when it changes.
    var qrScanPublisher: AnyPublisher<[ScanResult], Never> {
        qrScanResultSubject.eraseToAnyPublisher()
    }

    // MARK: Private Properties

    /// The `Coordinator` responsible for navigation-related actions.
    private let coordinator: any Coordinator<FileSelectionRoute, FileSelectionEvent>

    /// The services used by this processor, including camera authorization and error reporting.
    private let services: Services

    /// A subject cointaining the scan code results.
    private var qrScanResultSubject = CurrentValueSubject<[ScanResult], Never>([])

    // MARK: Intialization

    /// Creates a new `QrScannerProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The `Coordinator` responsible for managing navigation based on actions received.
    ///   - services: The services used by this processor, including access to the camera and error reporting.
    ///   - state: The initial state of this processor, representing the UI's state.
    ///
    init(
        coordinator: any Coordinator<FileSelectionRoute, FileSelectionEvent>,
        services: Services,
        state: QrScannerState
    ) {
        self.coordinator = coordinator
        self.services = services
        super.init(state: state)
    }

    override func perform(_ effect: QrScannerEffect) async {
        switch effect {
        case .appeared:
            await setupCameraResultsObservation()
        case .disappeared:
            services.cameraService.stopCameraSession()
        }
    }

    override func receive(_ action: QrScannerAction) {
//        switch action {
//        case .dismissPressed:
//            coordinator.navigate(to: .dismiss())
//        }
    }

    /// Sets up the camera for scanning QR codes.
    ///
    /// This method checks for camera support and initiates the camera session. If an error occurs,
    /// it logs the error through the provided error reporting service.
    ///
    private func setupCameraResultsObservation() async {
        guard services.cameraService.deviceSupportsCamera() else {
            return
        }

        for await value in services.cameraService.getScanResultPublisher() {
            guard let value else { continue }
            Logger.application.log("Value is here")
            await coordinator.handleEvent(.qrScanFinished(value: value))
            return
        }
    }
}
