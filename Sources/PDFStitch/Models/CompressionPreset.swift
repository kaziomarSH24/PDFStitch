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
        case .maxCompress: return 72.0
        case .balanced: return 85.0
        case .highQuality: return 150.0
        case .original: return 300.0
        }
    }

    /// JPEG compression factor (0.0 = smallest size, 1.0 = lossless)
    public var jpegQuality: CGFloat {
        switch self {
        case .maxCompress: return 0.15
        case .balanced: return 0.25
        case .highQuality: return 0.65
        case .original: return 1.0
        }
    }

    /// Descriptive helper string for UI display
    public var description: String {
        switch self {
        case .maxCompress: return "72 DPI - Smallest file for email & web"
        case .balanced: return "85 DPI - Recommended balance of clarity & size"
        case .highQuality: return "150 DPI - Sharp for print & crisp reading"
        case .original: return "300 DPI - Preserves original resolution"
        }
    }
}
