import AVFoundation
import SwiftUI

// MARK: - ScanCodeView

/// A view that shows the camera to scan QR codes.
struct QrScannerView: View {
    // MARK: Properties

    /// The AVCaptureSession used to scan qr codes
    let cameraSession: AVCaptureSession

    /// The maximum dynamic type size for the view
    ///     Default is `.xxLarge`
    var maxDynamicTypeSize: DynamicTypeSize = .xxLarge

    /// The `Store` for this view.
    @ObservedObject var store: Store<QrScannerState, QrScannerAction, QrScannerEffect>

    // MARK: Views

    var body: some View {
        content
            .background(Asset.Colors.backgroundSecondary.swiftUIColor.ignoresSafeArea())
            .navigationTitle(Localizations.scanQrTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelToolbarItem {
                    store.send(.dismissPressed)
                }
            }
            .task {
                await store.perform(.appeared)
            }
            .onDisappear {
                Task {
                    await store.perform(.disappeared)
                }
            }
    }

    var content: some View {
        ZStack {
            CameraPreviewView(session: cameraSession)
            overlayContent
        }
        .edgesIgnoringSafeArea(.horizontal)
    }

    var informationContent: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(Localizations.pointYourCameraAtTheQRCode)
                .styleGuide(.body)
                .multilineTextAlignment(.center)
                .dynamicTypeSize(...maxDynamicTypeSize)
                .foregroundColor(.white)
        }
    }

    @ViewBuilder var overlayContent: some View {
        GeometryReader { proxy in
            if proxy.size.width <= proxy.size.height {
                verticalOverlay
            } else {
                horizontalOverlay
            }
        }
    }

    private var horizontalOverlay: some View {
        GeometryReader { geoProxy in
            let size = geoProxy.size
            let orientation = UIDevice.current.orientation
            let infoBlock = infoBlock(width: size.width / 3, height: size.height)
            HStack(spacing: 0.0) {
                if case .landscapeRight = orientation {
                    infoBlock
                }
                Spacer()
                qrCornerGuides(length: size.height)
                Spacer()
                if orientation != .landscapeRight {
                    infoBlock
                }
            }
        }
    }

    private var verticalOverlay: some View {
        GeometryReader { geoProxy in
            let size = geoProxy.size
            VStack(spacing: 0.0) {
                Spacer()
                qrCornerGuides(length: size.width)
                Spacer()
                infoBlock(width: size.width, height: size.height / 3)
            }
        }
    }

    private func infoBlock(width: CGFloat, height: CGFloat) -> some View {
        Rectangle()
            .frame(
                width: width,
                height: height
            )
            .foregroundColor(.black)
            .opacity(0.5)
            .overlay {
                informationContent
                    .padding(36)
            }
    }

    private func qrCornerGuides(length: CGFloat) -> some View {
        CornerBorderShape(cornerLength: length * 0.1, lineWidth: 3)
            .stroke(lineWidth: 3)
            .foregroundColor(Asset.Colors.primaryBitwardenLight.swiftUIColor)
            .frame(
                width: length * 0.65,
                height: length * 0.65
            )
    }
}

#if DEBUG
struct QrScannerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QrScannerView(
                cameraSession: AVCaptureSession(),
                store: Store(
                    processor: StateProcessor(
                        state: QrScannerState()
                    )
                )
            )
        }
        .navigationViewStyle(.stack)
        .previewDisplayName("Scan Code View")
    }
}
#endif
