@testable import AuthenticatorShared

// MARK: - MockAppModule

class MockAppModule:
    AppModule,
    ItemListModule {
    var appCoordinator = MockCoordinator<AppRoute, AppEvent>()
    var itemsCoordinator = MockCoordinator<ItemListRoute, ItemListEvent>()

    func makeAppCoordinator(
        appContext _: AppContext,
        navigator _: RootNavigator
    ) -> AnyCoordinator<AppRoute, AppEvent> {
        appCoordinator.asAnyCoordinator()
    }

    func makeItemsCoordinator(
        stackNavigator _: AuthenticatorShared.StackNavigator
    ) -> AnyCoordinator<ItemListRoute, ItemListEvent> {
        itemsCoordinator.asAnyCoordinator()
    }
}
