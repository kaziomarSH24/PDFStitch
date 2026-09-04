import Foundation
import AppKit
import PDFKit

/// Renders images onto standard PDF pages (such as A4) with compression
public enum PDFPageRenderer {

    /// Renders an NSImage centered onto a standardized page with white margins
    public static func renderPage(
        from image: NSImage,
        pageSize: CGSize,
        targetDPI: CGFloat,
        quality: CGFloat,
        isOriginalSize: Bool
    ) -> PDFPage? {
        let scale = targetDPI / 72.0
        let pixelWidth = max(1, Int(pageSize.width * scale))
        let pixelHeight = max(1, Int(pageSize.height * scale))

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: pixelWidth,
                height: pixelHeight,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
              ) else {
            return PDFPage(image: image)
        }

        // Fill background with solid white
        context.setFillColor(CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))

        // Calculate aspect-fit drawing area
        let drawRectPt: CGRect
        if isOriginalSize {
            drawRectPt = CGRect(origin: .zero, size: pageSize)
        } else {
            let margin: CGFloat = 12.0
            let printableWidth = max(10, pageSize.width - (margin * 2))
            let printableHeight = max(10, pageSize.height - (margin * 2))

            let imgRatio = max(0.001, image.size.width / image.size.height)
            let pageRatio = printableWidth / printableHeight

            let drawW = imgRatio > pageRatio ? printableWidth : printableHeight * imgRatio
            let drawH = imgRatio > pageRatio ? printableWidth / imgRatio : printableHeight

            let drawX = margin + (printableWidth - drawW) / 2.0
            let drawY = margin + (printableHeight - drawH) / 2.0
            drawRectPt = CGRect(x: drawX, y: drawY, width: drawW, height: drawH)
        }

        let drawRectPx = CGRect(
            x: drawRectPt.origin.x * scale,
            y: drawRectPt.origin.y * scale,
            width: drawRectPt.size.width * scale,
            height: drawRectPt.size.height * scale
        )

        context.interpolationQuality = .high
        if let tiff = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff),
           let cgImage = bitmap.cgImage {
            context.draw(cgImage, in: drawRectPx)
        }

        guard let finalCG = context.makeImage() else {
            return PDFPage(image: image)
        }

        let finalBitmap = NSBitmapImageRep(cgImage: finalCG)
        let props: [NSBitmapImageRep.PropertyKey: Any] = [.compressionFactor: quality]

        guard let jpegData = finalBitmap.representation(using: .jpeg, properties: props),
              let compressedImage = NSImage(data: jpegData) else {
            return PDFPage(image: image)
        }

        compressedImage.size = pageSize
        return PDFPage(image: compressedImage)
    }
}
