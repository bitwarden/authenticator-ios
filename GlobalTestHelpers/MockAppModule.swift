@testable import AuthenticatorShared

// MARK: - MockAppModule

class MockAppModule:
    AppModule,
    TokenListModule {
    var appCoordinator = MockCoordinator<AppRoute, AppEvent>()
    var tokenListCoordinator = MockCoordinator<TokenListRoute, TokenListEvent>()

    func makeAppCoordinator(
        appContext _: AppContext,
        navigator _: RootNavigator
    ) -> AnyCoordinator<AppRoute, AppEvent> {
        appCoordinator.asAnyCoordinator()
    }

    func makeTokenListCoordinator(
        stackNavigator _: AuthenticatorShared.StackNavigator
    ) -> AnyCoordinator<TokenListRoute, TokenListEvent> {
        tokenListCoordinator.asAnyCoordinator()
    }
}
