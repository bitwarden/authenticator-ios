/// A top level route from the initial screen of the app to anywhere in the app.
///
public enum AppRoute: Equatable {
    /// A route to the tab interface.
    case tab(TabRoute)

    /// A route to the welcome tutorial.
    case tutorial
}

public enum AppEvent: Equatable {
    /// When the app has started.
    case didStart
}
