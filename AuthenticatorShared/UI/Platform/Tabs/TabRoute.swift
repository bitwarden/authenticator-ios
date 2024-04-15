import UIKit

// MARK: - TabRoute

/// The enumeration of tabs displayed by the application.
///
public enum TabRoute: Equatable, Hashable {
    /// The verification codes
    case itemList(ItemListRoute)

    case tutorial(TutorialRoute)

    /// The settings tab.
    case settings(SettingsRoute)
}

// MARK: - TabRepresentable

extension TabRoute: TabRepresentable {
    public var image: UIImage? {
        switch self {
        case .itemList: return Asset.Images.lockedFilled.image
        case .settings: return Asset.Images.gearFilled.image
        case .tutorial: return Asset.Images.camera.image
        }
    }

    public var index: Int {
        switch self {
        case .itemList: return 0
        case .settings: return 1
        case .tutorial: return 2
        }
    }

    public var selectedImage: UIImage? {
        switch self {
        case .itemList: return Asset.Images.lockedFilled.image
        case .settings: return Asset.Images.gearFilled.image
        case .tutorial: return Asset.Images.camera.image
        }
    }

    public var title: String {
        switch self {
        case .itemList: return Localizations.verificationCodes
        case .settings: return Localizations.settings
        case .tutorial: return "Tutorial"
        }
    }
}
