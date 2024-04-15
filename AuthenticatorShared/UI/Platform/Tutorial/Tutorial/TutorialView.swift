import SwiftUI

// MARK: - TutorialView

/// A view containing the tutorial screens
///
struct TutorialView: View {
    // MARK: Properties

    /// The `Store` for this view.
    @ObservedObject var store: Store<TutorialState, TutorialAction, TutorialEffect>

    // MARK: View

    var body: some View {
        content
            .navigationBar(title: "Bitwarden Authenticator", titleDisplayMode: .inline)
    }

    // MARK: Private Properties

    private var content: some View {
        VStack(spacing: 24) {
            Spacer()
            TabView {
                page1
                page2
                page3
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .padding(.top, 16)

            Button("Continue") {}
                .buttonStyle(.primary())

            Button("Skip") {}
                .buttonStyle(InlineButtonStyle())
        }
        .padding(16)
        .background(Asset.Colors.backgroundSecondary.swiftUIColor.ignoresSafeArea())
    }

    private var page1: some View {
        VStack(spacing: 24) {
            Asset.Images.recoveryCodes.swiftUIImage
                .frame(height: 140)

            Text("Secure your accounts with Bitwarden Authenticator")
                .styleGuide(.title2)

            Text("Get verification codes for all your accounts using 2-step verification.")

            Spacer()
        }
        .multilineTextAlignment(.center)
    }

    private var page2: some View {
        VStack(spacing: 24) {
            Asset.Images.qrIllustration.swiftUIImage
                .frame(height: 140)

            Text("User your device camera to scan codes")
                .styleGuide(.title2)

            Text("Scan the QR code in your 2-step verification settings for any account.")

            Spacer()
        }
        .multilineTextAlignment(.center)
    }

    private var page3: some View {
        VStack(spacing: 24) {
            Asset.Images.uniqueCodes.swiftUIImage
                .frame(height: 140)

            Text("Sign in using unique codes")
                .styleGuide(.title2)

            Text("When using 2-step verification, you’ll enter your username and password and a code generated in this app.")

            Spacer()
        }
        .multilineTextAlignment(.center)
    }
}

#Preview("Tutorial") {
    NavigationView {
        TutorialView(
            store: Store(
                processor: StateProcessor(
                    state: TutorialState()
                )
            )
        )
    }
}
