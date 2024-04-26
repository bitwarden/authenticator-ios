import SwiftUI

// MARK: - TutorialView

/// A view containing the tutorial screens
///
struct TutorialView: View {
    // MARK: Properties

    /// The `Store` for this view.
    @ObservedObject var store: Store<TutorialState, TutorialAction, TutorialEffect>

    /// The vertical size class to determine if we're in landscape mode.
    @Environment(\.verticalSizeClass) var verticalSizeClass

    // MARK: View

    var body: some View {
        content
            .navigationBar(title: Localizations.bitwardenAuthenticator, titleDisplayMode: .inline)
    }

    // MARK: Private Properties

    private var content: some View {
//        if verticalSizeClass == .regular {
//            portraitContent
//        } else {
//            landscapeContent
//        }
//    }
//
//    private var portraitContent: some View {
        VStack(spacing: 24) {
            Spacer()
            TabView(
                selection: store.binding(
                    get: \.page,
                    send: TutorialAction.pageChanged
                )
            ) {
                introSlide.tag(TutorialPage.intro)
                qrScannerSlide.tag(TutorialPage.qrScanner)
                uniqueCodesSlide.tag(TutorialPage.uniqueCodes)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .padding(.top, 16)
            .animation(.default, value: store.state.page)
            .transition(.slide)

            Button(store.state.continueButtonText) {
                store.send(.continueTapped)
            }
            .buttonStyle(.primary())

            if verticalSizeClass == .regular {
                Button {
                    store.send(.skipTapped)
                } label: {
                    Text(Localizations.skip)
                        .foregroundColor(Asset.Colors.primaryBitwarden.swiftUIColor)
                }
                .buttonStyle(InlineButtonStyle())
                .hidden(store.state.isLastPage)
            }
        }
        .padding(16)
        .background(Asset.Colors.backgroundSecondary.swiftUIColor.ignoresSafeArea())
    }

//    private var landscapeContent: some View {
//        VStack(spacing: 24) {
//            Spacer()
//            TabView(
//                selection: store.binding(
//                    get: \.page,
//                    send: TutorialAction.pageChanged
//                )
//            ) {
//                introSlide.tag(TutorialPage.intro)
//                qrScannerSlide.tag(TutorialPage.qrScanner)
//                uniqueCodesSlide.tag(TutorialPage.uniqueCodes)
//            }
//            .tabViewStyle(.page(indexDisplayMode: .always))
//            .indexViewStyle(.page(backgroundDisplayMode: .always))
//            .padding(.top, 16)
//            .animation(.default, value: store.state.page)
//            .transition(.slide)
//
//            Button(store.state.continueButtonText) {
//                store.send(.continueTapped)
//            }
//            .buttonStyle(.primary())
//
//            Button {
//                store.send(.skipTapped)
//            } label: {
//                Text(Localizations.skip)
//                    .foregroundColor(Asset.Colors.primaryBitwarden.swiftUIColor)
//            }
//            .buttonStyle(InlineButtonStyle())
//            .hidden(store.state.isLastPage)
//        }
//        .padding(16)
//        .background(Asset.Colors.backgroundSecondary.swiftUIColor.ignoresSafeArea())
//    }

    @ViewBuilder private var introSlide: some View {
        if verticalSizeClass == .regular {
            VStack(spacing: 24) {
                Image(decorative: Asset.Images.recoveryCodesBig)
                    .frame(height: 146)

                Text(Localizations.secureYourAssetsWithBitwardenAuthenticator)
                    .styleGuide(.title2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(Localizations.getVerificationCodesForAllYourAccounts)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .multilineTextAlignment(.center)
        } else {
            HStack(spacing: 24) {
                Image(decorative: Asset.Images.recoveryCodesBig)
                    .frame(height: 146)

                VStack(spacing: 24) {
                    Spacer()

                    Text(Localizations.secureYourAssetsWithBitwardenAuthenticator)
                        .styleGuide(.title2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(Localizations.getVerificationCodesForAllYourAccounts)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
            }
            .multilineTextAlignment(.center)
        }
    }

    private var qrScannerSlide: some View {
        VStack(spacing: 24) {
            Image(decorative: Asset.Images.qrIllustration)
                .frame(height: 146)

            Text(Localizations.useYourDeviceCameraToScanCodes)
                .styleGuide(.title2)

            Text(Localizations.scanTheQRCodeInYourSettings)

            Spacer()
        }
        .multilineTextAlignment(.center)
    }

    private var uniqueCodesSlide: some View {
        VStack(spacing: 24) {
            Asset.Images.verificationCode.swiftUIImage
                .frame(height: 146)

            Text(Localizations.signInUsingUniqueCodes)
                .styleGuide(.title2)

            Text(Localizations.whenUsingTwoStepVerification)

            Spacer()
        }
        .multilineTextAlignment(.center)
    }
}

#if DEBUG
#Preview("Intro") {
    NavigationView {
        TutorialView(
            store: Store(
                processor: StateProcessor(
                    state: TutorialState(page: .intro)
                )
            )
        )
    }
}

#Preview("QR Scanner") {
    NavigationView {
        TutorialView(
            store: Store(
                processor: StateProcessor(
                    state: TutorialState(page: .qrScanner)
                )
            )
        )
    }
}

#Preview("Unique Codes") {
    NavigationView {
        TutorialView(
            store: Store(
                processor: StateProcessor(
                    state: TutorialState(page: .uniqueCodes)
                )
            )
        )
    }
}
#endif
