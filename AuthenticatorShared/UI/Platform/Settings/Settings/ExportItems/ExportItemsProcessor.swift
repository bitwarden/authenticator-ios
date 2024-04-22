import Foundation

// MARK: - ExportItemsProcessor

/// The processor used to manage state and handle actions for an `ExportItemsView`.
final class ExportItemsProcessor: StateProcessor<ExportItemsState, ExportItemsAction, ExportItemsEffect> {
    // MARK: Types

    typealias Services = HasErrorReporter
        & HasExportItemsService

    // MARK: Properties

    /// The coordinator used to manage navigation.
    private let coordinator: AnyCoordinator<SettingsRoute, SettingsEvent>

    /// The services used by this processor.
    private let services: Services

    // MARK: Initialization

    /// Initializes a new `ExportItemsProcessor`.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator used for navigation.
    ///   - services: The services used by the processor.
    ///
    init(
        coordinator: AnyCoordinator<SettingsRoute, SettingsEvent>,
        services: Services
    ) {
        self.coordinator = coordinator
        self.services = services
        super.init(state: ExportItemsState())
    }

    deinit {
        // When the view is dismissed, ensure any temporary files are deleted.
        services.exportItemsService.clearTemporaryFiles()
    }

    // MARK: Methods

    override func perform(_ effect: ExportItemsEffect) async {
        switch effect {
        case .loadData:
            break
        }
    }

    override func receive(_ action: ExportItemsAction) {
        switch action {
        case .dismiss:
            services.exportItemsService.clearTemporaryFiles()
            coordinator.navigate(to: .dismiss)
        case .exportTapped:
            break
        case .fileFormatTypeChanged:
            break
        }
    }

}
