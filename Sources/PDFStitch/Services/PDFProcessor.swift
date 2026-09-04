import Foundation
import AppKit
import PDFKit

/// High-level engine coordinating file loading and PDF export
public class PDFProcessor {
    public static let shared = PDFProcessor()
    private init() {}

    /// Imports images and multi-page PDFs into an array of PageItem models
    public func loadItems(from urls: [URL], progress: @escaping (String) -> Void) async -> [PageItem] {
        var items: [PageItem] = []

        for url in urls {
            let ext = url.pathExtension.lowercased()
            progress("Loading \(url.lastPathComponent)...")

            if ext == "pdf" {
                if let doc = PDFDocument(url: url) {
                    let total = doc.pageCount
                    let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0

                    for i in 0..<total {
                        guard let page = doc.page(at: i) else { continue }
                        let size = page.bounds(for: .cropBox).size
                        let thumb = page.thumbnail(of: CGSize(width: 240, height: 320), for: .cropBox)
                        let title = total > 1 ? "\(url.deletingPathExtension().lastPathComponent) (Page \(i + 1))" : url.lastPathComponent

                        items.append(PageItem(
                            sourceURL: url,
                            sourceType: .pdfPage(pageIndex: i, totalPages: total),
                            title: title,
                            thumbnail: thumb,
                            originalSize: size,
                            fileSizeBytes: fileSize / Int64(max(1, total))
                        ))
                    }
                }
            } else if ["jpg", "jpeg", "png", "heic", "tiff", "webp"].contains(ext) {
                if let image = NSImage(contentsOf: url) {
                    let thumb = ImageHelper.createThumbnail(for: image, targetSize: CGSize(width: 240, height: 320))
                    let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0

                    items.append(PageItem(
                        sourceURL: url,
                        sourceType: .image,
                        title: url.lastPathComponent,
                        thumbnail: thumb,
                        originalSize: image.size,
                        fileSizeBytes: fileSize
                    ))
                }
            }
        }
        return items
    }

    /// Asynchronously renders and exports ordered PageItems into a single PDF
    public func exportPDF(
        items: [PageItem],
        preset: CompressionPreset,
        pageSizeMode: PageSizeMode,
        customDPI: CGFloat?,
        customQuality: CGFloat?,
        to outputURL: URL,
        progress: @escaping (Int, Int) -> Void
    ) async throws {
        let dpi = customDPI ?? preset.dpi
        let quality = customQuality ?? preset.jpegQuality
        let isOriginalCompression = preset == .original && customDPI == nil
        let isOriginalPageSize = pageSizeMode == .original

        let doc = PDFDocument()

        for (index, item) in items.enumerated() {
            progress(index + 1, items.count)

            var rendered: NSImage?
            switch item.sourceType {
            case .image:
                if let raw = NSImage(contentsOf: item.sourceURL) {
                    rendered = ImageHelper.rotate(image: raw, by: item.rotationDegrees)
                }
            case .pdfPage(let pIdx, _):
                if let src = PDFDocument(url: item.sourceURL), let page = src.page(at: pIdx) {
                    let bounds = page.bounds(for: .cropBox)
                    let scale = isOriginalCompression ? 2.5 : (dpi / 72.0)
                    let pSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)
                    let img = page.thumbnail(of: pSize, for: .cropBox)
                    rendered = ImageHelper.rotate(image: img, by: item.rotationDegrees)
                }
            }

            guard let finalImg = rendered else { continue }
            let pageSize = pageSizeMode.dimensions(for: finalImg)

            if let pdfPage = PDFPageRenderer.renderPage(
                from: finalImg,
                pageSize: pageSize,
                targetDPI: dpi,
                quality: isOriginalCompression ? 0.95 : quality,
                isOriginalSize: isOriginalPageSize
            ) {
                doc.insert(pdfPage, at: doc.pageCount)
            }
        }

        guard doc.pageCount > 0 else {
            throw NSError(domain: "PDFProcessor", code: -1, userInfo: [NSLocalizedDescriptionKey: "No pages processed."])
        }

        doc.write(to: outputURL)
    }
}
