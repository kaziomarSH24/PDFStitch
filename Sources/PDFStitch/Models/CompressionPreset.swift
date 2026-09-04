import Foundation
import CoreGraphics

/// Preset configurations for compression quality and resolution
public enum CompressionPreset: String, CaseIterable, Identifiable {
    case maxCompress = "Low (Smallest Size)"
    case balanced = "Medium (Balanced)"
    case highQuality = "High (Print Quality)"
    case original = "Maximum (Original)"

    public var id: String { rawValue }

    /// Target resolution in DPI (Dots Per Inch)
    public var dpi: CGFloat {
        switch self {
        case .maxCompress: return 85.0
        case .balanced: return 110.0
        case .highQuality: return 150.0
        case .original: return 300.0
        }
    }

    /// JPEG compression factor (0.0 = smallest size, 1.0 = lossless)
    public var jpegQuality: CGFloat {
        switch self {
        case .maxCompress: return 0.30
        case .balanced: return 0.48
        case .highQuality: return 0.70
        case .original: return 0.95
        }
    }

    /// Descriptive helper string for UI display
    public var description: String {
        switch self {
        case .maxCompress: return "85 DPI - Compact file size for email & web"
        case .balanced: return "110 DPI - Crisp readable text, optimized for < 9MB"
        case .highQuality: return "150 DPI - Sharp for print & high resolution"
        case .original: return "300 DPI - Preserves original resolution"
        }
    }
}
