import Foundation
import AppKit

/// Standard paper sizes supported by PDFStitch
public enum PageSizeMode: String, CaseIterable, Identifiable {
    case a4Portrait = "A4 (Standard)"
    case a4Auto = "A4 Auto (Orientation)"
    case original = "Original (No Resizing)"

    public var id: String { rawValue }

    /// Calculates output dimensions in PDF points (72 pt = 1 inch)
    public func dimensions(for image: NSImage) -> CGSize {
        // Standard ISO A4 dimensions: 210 x 297 mm = 595.28 x 841.89 points
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
