import SwiftUI
import PDFKit

/// SwiftUI wrapper around Apple native PDFView for smooth PDF reading and zooming
public struct PDFKitRepresentedView: NSViewRepresentable {
    public let document: PDFDocument
    @Binding public var pdfViewReference: PDFView?

    public init(document: PDFDocument, pdfViewReference: Binding<PDFView?> = .constant(nil)) {
        self.document = document
        self._pdfViewReference = pdfViewReference
    }

    public func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displaysPageBreaks = true
        pdfView.backgroundColor = NSColor.underPageBackgroundColor

        DispatchQueue.main.async {
            self.pdfViewReference = pdfView
        }
        return pdfView
    }

    public func updateNSView(_ pdfView: PDFView, context: Context) {
        if pdfView.document !== document {
            pdfView.document = document
            pdfView.autoScales = true
        }
    }
}
