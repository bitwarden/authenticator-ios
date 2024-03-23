import Foundation

// MARK: - TokenListModule

/// An object that builds coordinators for the Token List screen.
@MainActor
protocol TokenListModule {
    /// Initializes a coordinator for navigating between `TokenListRoute`s
    ///
    /// - Parameters:
    ///   - delegate: A delegate of the `TokenListCoordinator`.
    ///   - stackNavigator: The stack navigator that will be used to navigate between routes.
    /// - Returns: A coordinator that can navigate to `TokenListRoute`s
    ///
    func makeTokenListCoordinator(
        stackNavigator: StackNavigator
    ) -> AnyCoordinator<TokenListRoute, TokenListEvent>
}

extension DefaultAppModule: TokenListModule {
    func makeTokenListCoordinator(
        stackNavigator: StackNavigator
    ) -> AnyCoordinator<TokenListRoute, TokenListEvent> {
        TokenListCoordinator(
            module: self,
            services: services,
            stackNavigator: stackNavigator
        ).asAnyCoordinator()
    }
}
