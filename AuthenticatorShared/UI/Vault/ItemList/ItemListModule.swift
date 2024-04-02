import Foundation

// MARK: - ItemListModule

/// An object that builds coordinators for the Token List screen.
@MainActor
protocol ItemListModule {
    /// Initializes a coordinator for navigating between `ItemsRoute`s
    ///
    /// - Parameters:
    ///   - delegate: A delegate of the `ItemsCoordinator`.
    ///   - stackNavigator: The stack navigator that will be used to navigate between routes.
    /// - Returns: A coordinator that can navigate to `ItemsRoute`s
    ///
    func makeItemsCoordinator(
        stackNavigator: StackNavigator
    ) -> AnyCoordinator<ItemsRoute, ItemsEvent>
}

extension DefaultAppModule: ItemListModule {
    func makeItemsCoordinator(
        stackNavigator: StackNavigator
    ) -> AnyCoordinator<ItemsRoute, ItemsEvent> {
        ItemsCoordinator(
            module: self,
            services: services,
            stackNavigator: stackNavigator
        ).asAnyCoordinator()
    }
}
