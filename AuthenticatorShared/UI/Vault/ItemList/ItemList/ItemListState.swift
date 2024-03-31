import Foundation

// MARK: - ItemListState

/// The state of a `ItemListView`.
struct ItemListState: Equatable {
    // MARK: Properties

    /// Whether there is data for the vault group.
    var emptyData: Bool {
        loadingState.data.isEmptyOrNil
    }

    /// The base url used to fetch icons.
    var iconBaseURL: URL?

    /// The current loading state.
    var loadingState: LoadingState<[VaultListItem]> = .loading(nil)

    /// The string to use in the empty view.
    var noItemsString: String {
        Localizations.noItems
    }

    /// Whether to show the add item button in the view.
    var showAddItemButton: Bool {
        // Don't show if there is data.
        guard emptyData else { return false }
        return true
    }

    /// Whether to show the add item button in the toolbar.
    var showAddToolbarItem: Bool {
        true
    }

    /// Whether to show the special web icons.
    var showWebIcons = true

    /// A toast message to show in the view.
    var toast: Toast?

    /// The url to open in the device's web browser.
    var url: URL?
}