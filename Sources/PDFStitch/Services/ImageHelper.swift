import Foundation
import AppKit

/// Utility class for fast thumbnail generation and image rotation
public enum ImageHelper {

    /// Generates a fast thumbnail from NSImage using CoreGraphics Image Source
    public static func createThumbnail(for image: NSImage, targetSize: CGSize) -> NSImage {
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

    /// Rotates an NSImage clockwise by degrees (90, 180, 270)
    public static func rotate(image: NSImage, by degrees: Int) -> NSImage {
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
}
