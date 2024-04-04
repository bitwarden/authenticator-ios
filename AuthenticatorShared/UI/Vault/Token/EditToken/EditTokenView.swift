import BitwardenSdk
import SwiftUI

/// A view for editing a token
struct EditTokenView: View {
    // MARK: Properties

    @ObservedObject var store: Store<EditTokenState, EditTokenAction, EditTokenEffect>

    // MARK: View

    var body: some View {
        Text("Hello world")
    }
}

#if DEBUG
#Preview("Loading") {
    EditTokenView(
        store: Store(
            processor: StateProcessor(
                state: TokenItemState(
                    configuration: .existing(
                        token: Token(
                            name: "Example",
                            authenticatorKey: "example"
                        )!
                    ),
                    name: "Example",
                    totpState: LoginTOTPState(
                        authKeyModel: TOTPKeyModel(authenticatorKey: "example")!,
                        codeModel: TOTPCodeModel(
                            code: "123456",
                            codeGenerationDate: Date(timeIntervalSinceReferenceDate: 0),
                            period: 30
                        )
                    )
                )
                .editState
            )
        )
    )
}
#endif
