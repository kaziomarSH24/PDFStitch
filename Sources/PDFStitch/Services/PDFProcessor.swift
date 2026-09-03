import Foundation
import AppKit
import PDFKit
import Quartz

public enum PageSizeMode: String, CaseIterable, Identifiable {
    case a4Portrait = "A4 (Standard)"
    case a4Auto = "A4 Auto (Orientation)"
    case original = "Original (No Resizing)"

    public var id: String { rawValue }

    public func dimensions(for image: NSImage) -> CGSize {
        let a4Width: CGFloat = 595.28
        let a4Height: CGFloat = 841.89

        switch self {
        case .a4Portrait:
            return CGSize(width: a4Width, height: a4Height)
        case .a4Auto:
            let isLandscape = image.size.width > image.size.height
            return isLandscape ? CGSize(width: a4Height, height: a4Width) : CGSize(width: a4Width, height: a4Height)
        case .original:
            return image.size
        }
    }
}

public enum CompressionPreset: String, CaseIterable, Identifiable {
    case maxCompress = "Maximum (< 5 MB)"
    case balanced = "Balanced (< 9 MB)"
    case highQuality = "High Quality"
    case original = "Original Quality"

    public var id: String { rawValue }

    public var dpi: CGFloat {
        switch self {
        case .maxCompress: return 72.0
        case .balanced: return 85.0
        case .highQuality: return 150.0
        case .original: return 300.0
        }
    }

    public var jpegQuality: CGFloat {
        switch self {
        case .maxCompress: return 0.15
        case .balanced: return 0.25
        case .highQuality: return 0.65
        case .original: return 1.0
        }
    }

    public var description: String {
        switch self {
        case .maxCompress: return "72 DPI - Great for email & chat"
        case .balanced: return "85 DPI - Optimized for < 9MB limit"
        case .highQuality: return "150 DPI - Sharp reading & printing"
        case .original: return "Original DPI - Source quality"
        }
    }
}

public class PDFProcessor {
    public static let shared = PDFProcessor()

    private init() {}

    /// Import files (images and PDFs) and return PageItems
    public func loadItems(from urls: [URL], progress: @escaping (String) -> Void) async -> [PageItem] {
        var items: [PageItem] = []

        for url in urls {
            let ext = url.pathExtension.lowercased()
            progress("Loading \(url.lastPathComponent)...")

            if ext == "pdf" {
                if let doc = PDFDocument(url: url) {
                    let totalPages = doc.pageCount
                    let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0

                    for i in 0..<totalPages {
                        guard let page = doc.page(at: i) else { continue }
                        let pageSize = page.bounds(for: .cropBox).size
                        let thumb = page.thumbnail(of: CGSize(width: 240, height: 320), for: .cropBox)

                        let title = totalPages > 1 ? "\(url.deletingPathExtension().lastPathComponent) (Page \(i + 1))" : url.lastPathComponent
                        let item = PageItem(
                            sourceURL: url,
                            sourceType: .pdfPage(pageIndex: i, totalPages: totalPages),
                            title: title,
                            thumbnail: thumb,
                            originalSize: pageSize,
                            fileSizeBytes: fileSize / Int64(max(1, totalPages))
                        )
                        items.append(item)
                    }
                }
            } else if ["jpg", "jpeg", "png", "heic", "tiff", "webp"].contains(ext) {
                if let image = NSImage(contentsOf: url) {
                    let thumb = createThumbnail(for: image, targetSize: CGSize(width: 240, height: 320))
                    let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0

                    let item = PageItem(
                        sourceURL: url,
                        sourceType: .image,
                        title: url.lastPathComponent,
                        thumbnail: thumb,
                        originalSize: image.size,
                        fileSizeBytes: fileSize
                    )
                    items.append(item)
                }
            }
        }

        return items
    }

    /// Fast thumbnail generation
    private func createThumbnail(for image: NSImage, targetSize: CGSize) -> NSImage {
        guard let tiff = image.tiffRepresentation,
              let source = CGImageSourceCreateWithData(tiff as CFData, nil) else {
            return image
        }

        let maxDim = max(targetSize.width, targetSize.height)
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDim
        ]

        if let cgThumb = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) {
            return NSImage(cgImage: cgThumb, size: targetSize)
        }
        return image
    }

    /// Rotate an NSImage
    private func rotate(image: NSImage, by degrees: Int) -> NSImage {
        let normalizedDegrees = ((degrees % 360) + 360) % 360
        if normalizedDegrees == 0 { return image }

        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        guard let imageRep = image.bestRepresentation(for: imageRect, context: nil, hints: nil) else {
            return image
        }

        let isPerpendicular = normalizedDegrees == 90 || normalizedDegrees == 270
        let newSize = isPerpendicular ? CGSize(width: image.size.height, height: image.size.width) : image.size

        let rotatedImage = NSImage(size: newSize)
        rotatedImage.lockFocus()

        let transform = NSAffineTransform()
        transform.translateX(by: newSize.width / 2, yBy: newSize.height / 2)
        transform.rotate(byDegrees: CGFloat(-normalizedDegrees))
        transform.translateX(by: -image.size.width / 2, yBy: -image.size.height / 2)
        transform.concat()

        imageRep.draw(in: imageRect)
        rotatedImage.unlockFocus()

        return rotatedImage
    }

    /// Export pages to unified PDF with selected compression & page size
    public func exportPDF(
        items: [PageItem],
        preset: CompressionPreset,
        pageSizeMode: PageSizeMode = .a4Portrait,
        customDPI: CGFloat? = nil,
        customQuality: CGFloat? = nil,
        to outputURL: URL,
        progress: @escaping (Int, Int) -> Void
    ) async throws {
        let targetDPI = customDPI ?? preset.dpi
        let targetQuality = customQuality ?? preset.jpegQuality
        let isOriginalCompression = preset == .original && customDPI == nil
        let isOriginalPageSize = pageSizeMode == .original

        let outputDoc = PDFDocument()
        let total = items.count

        for (index, item) in items.enumerated() {
            progress(index + 1, total)

            // Direct passthrough only if original compression, original size, and 0 rotation
            if isOriginalCompression && isOriginalPageSize && item.rotationDegrees == 0 {
                if case .pdfPage(let pageIndex, _) = item.sourceType,
                   let srcDoc = PDFDocument(url: item.sourceURL),
                   let page = srcDoc.page(at: pageIndex) {
                    outputDoc.insert(page, at: outputDoc.pageCount)
                    continue
                }
            }

            // Render to image
            var renderedImage: NSImage?

            switch item.sourceType {
            case .image:
                if let rawImage = NSImage(contentsOf: item.sourceURL) {
                    renderedImage = rotate(image: rawImage, by: item.rotationDegrees)
                }

            case .pdfPage(let pageIndex, _):
                if let srcDoc = PDFDocument(url: item.sourceURL),
                   let page = srcDoc.page(at: pageIndex) {
                    let bounds = page.bounds(for: .cropBox)
                    let scale = isOriginalCompression ? 2.5 : (targetDPI / 72.0)
                    let pixelSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)

                    let img = page.thumbnail(of: pixelSize, for: .cropBox)
                    renderedImage = rotate(image: img, by: item.rotationDegrees)
                }
            }

            guard let finalImage = renderedImage else { continue }

            let targetPageSize = pageSizeMode.dimensions(for: finalImage)

            // Render to standard page size (e.g. A4) with compression
            let pdfPage = createFittedPDFPage(
                from: finalImage,
                pageSize: targetPageSize,
                targetDPI: targetDPI,
                quality: isOriginalCompression ? 0.95 : targetQuality,
                isOriginalSize: isOriginalPageSize
            )

            if let page = pdfPage {
                outputDoc.insert(page, at: outputDoc.pageCount)
            }
        }

        guard outputDoc.pageCount > 0 else {
            throw NSError(domain: "PDFProcessor", code: -1, userInfo: [NSLocalizedDescriptionKey: "No pages were processed"])
        }

        outputDoc.write(to: outputURL)
    }

    /// Render image onto a standard page (e.g. A4) centered with white background & compression
    private func createFittedPDFPage(
        from image: NSImage,
        pageSize: CGSize,
        targetDPI: CGFloat,
        quality: CGFloat,
        isOriginalSize: Bool
    ) -> PDFPage? {
        let scale = targetDPI / 72.0
        let canvasPixelWidth = max(1, Int(pageSize.width * scale))
        let canvasPixelHeight = max(1, Int(pageSize.height * scale))

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: canvasPixelWidth,
                height: canvasPixelHeight,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
              ) else {
            return PDFPage(image: image)
        }

        // Fill background with clean solid white
        context.setFillColor(CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: canvasPixelWidth, height: canvasPixelHeight))

        // Calculate drawing rectangle
        let drawRectPt: CGRect
        if isOriginalSize {
            drawRectPt = CGRect(origin: .zero, size: pageSize)
        } else {
            // Fit image into A4 page with 12pt margin
            let marginPt: CGFloat = 12.0
            let printableWidth = max(10, pageSize.width - (marginPt * 2))
            let printableHeight = max(10, pageSize.height - (marginPt * 2))

            let imgRatio = max(0.001, image.size.width / image.size.height)
            let pageRatio = printableWidth / printableHeight

            let drawWidthPt: CGFloat
            let drawHeightPt: CGFloat

            if imgRatio > pageRatio {
                drawWidthPt = printableWidth
                drawHeightPt = printableWidth / imgRatio
            } else {
                drawHeightPt = printableHeight
                drawWidthPt = printableHeight * imgRatio
            }

            let drawXPt = marginPt + (printableWidth - drawWidthPt) / 2.0
            let drawYPt = marginPt + (printableHeight - drawHeightPt) / 2.0

            drawRectPt = CGRect(x: drawXPt, y: drawYPt, width: drawWidthPt, height: drawHeightPt)
        }

        let drawRectPixel = CGRect(
            x: drawRectPt.origin.x * scale,
            y: drawRectPt.origin.y * scale,
            width: drawRectPt.size.width * scale,
            height: drawRectPt.size.height * scale
        )

        context.interpolationQuality = .high
        if let tiff = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff),
           let cgImage = bitmap.cgImage {
            context.draw(cgImage, in: drawRectPixel)
        }

        guard let finalCG = context.makeImage() else {
            return PDFPage(image: image)
        }

        let finalBitmap = NSBitmapImageRep(cgImage: finalCG)
        let compressionProps: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: quality
        ]

        guard let jpegData = finalBitmap.representation(using: .jpeg, properties: compressionProps),
          let compressedImage = NSImage(data: jpegData) else {
            return PDFPage(image: image)
        }

        compressedImage.size = pageSize
        return PDFPage(image: compressedImage)
    }
}
