import Foundation

// MARK: - ImportItemsProcessor

/// The processor used to manage state and handle actions for an `ImportItemsView`.
final class ImportItemsProcessor: StateProcessor<ImportItemsState, ImportItemsAction, ImportItemsEffect> {
    // MARK: Types

    typealias Services = HasErrorReporter
        & HasImportItemsService

    // MARK: Properties

    /// The coordinator used to manage navigation.
    private let coordinator: AnyCoordinator<SettingsRoute, SettingsEvent>

    /// The services used by this processor.
    private let services: Services

    // MARK: Initialization

    /// Initializes a new `ImportItemsProcessor`.
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
        super.init(state: ImportItemsState())
    }

    // MARK: Methods

    override func perform(_ effect: ImportItemsEffect) async {
        switch effect {
        case .loadData:
            break
        }
    }

    override func receive(_ action: ImportItemsAction) {
        switch action {
        case .dismiss:
            coordinator.navigate(to: .dismiss)
        case .importItemsTapped:
            confirmImportItems()
        case let .fileFormatTypeChanged(fileFormat):
            state.fileFormat = fileFormat
        }
    }

    // MARK: - Private Methods

    /// Shows the alert to confirm the items import.
    private func confirmImportItems() {
        let importFormat: ImportFileType
        switch state.fileFormat {
        case .bitwardenJson:
            importFormat = .json
        }

        do {
//            try await self.services.importItemsService
//            let fileUrl = try await self.services.importItemsService.importItems(format: importFormat)
//            self.coordinator.navigate(to: .shareImportedItems(fileUrl))
        } catch {
            self.services.errorReporter.log(error: error)
        }
    }
}
