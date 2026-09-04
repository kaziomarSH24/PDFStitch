import SwiftUI
import PDFKit

/// Native PDF Reader screen with continuous scrolling, zoom controls, and quick action toolbar
public struct PDFReaderView: View {
    public let document: PDFDocument
    public let fileURL: URL
    public let onBackToDashboard: () -> Void
    public let onOrganize: () -> Void
    public let onCompress: () -> Void

    @State private var pdfView: PDFView? = nil

    public var body: some View {
        VStack(spacing: 0) {
            // Reader Navigation Toolbar
            HStack(spacing: 12) {
                Button(action: onBackToDashboard) {
                    Label("Dashboard", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)

                VStack(alignment: .leading, spacing: 1) {
                    Text(fileURL.lastPathComponent)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                    Text("\(document.pageCount) Pages")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: 220, alignment: .leading)

                Spacer()

                // Zoom & Scale Controls
                HStack(spacing: 4) {
                    Button(action: { pdfView?.zoomOut(nil) }) {
                        Image(systemName: "minus.magnifyingglass")
                    }.buttonStyle(.bordered).help("Zoom Out")

                    Button(action: { pdfView?.autoScales = true }) {
                        Text("Fit").font(.system(size: 11))
                    }.buttonStyle(.bordered).help("Fit to Window")

                    Button(action: { pdfView?.zoomIn(nil) }) {
                        Image(systemName: "plus.magnifyingglass")
                    }.buttonStyle(.bordered).help("Zoom In")
                }

                Divider().frame(height: 18)

                // Tool actions
                Button(action: onOrganize) {
                    Label("Organize Pages", systemImage: "square.stack.3d.up.fill")
                }
                .buttonStyle(.borderedProminent)

                Button(action: onCompress) {
                    Label("Compress", systemImage: "arrow.down.right.and.arrow.up.left")
                }
                .buttonStyle(.bordered)

                Button(action: {
                    pdfView?.print(with: NSPrintInfo.shared, autoRotate: true, pageScaling: .pageScaleNone)
                }) {
                    Image(systemName: "printer")
                }
                .buttonStyle(.bordered)
                .help("Print Document")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Native Apple PDF Viewer (Continuous vertical scroll)
            PDFKitRepresentedView(document: document, pdfViewReference: $pdfView)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}
