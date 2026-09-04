import Foundation

/// Available tools displayed on the Dashboard
public enum AppTool: String, CaseIterable, Identifiable {
    case organize = "Organize PDFs"
    case compress = "Compress PDF"
    case create = "Create PDF"
    case edit = "Edit PDF"
    case encrypt = "Encrypt PDF"
    case batch = "Batch Process"
    case print = "Print PDF"

    public var id: String { rawValue }

    /// SF Symbol icon name for the tool card
    public var iconName: String {
        switch self {
        case .organize: return "square.stack.3d.up.fill"
        case .compress: return "arrow.down.right.and.arrow.up.left"
        case .create: return "plus.rectangle.fill"
        case .edit: return "pencil.and.outline"
        case .encrypt: return "lock.shield.fill"
        case .batch: return "square.grid.2x2.fill"
        case .print: return "printer.fill"
        }
    }

    /// Short subtitle description
    public var subtitle: String {
        switch self {
        case .organize: return "Sort, add, reorder, and rotate pages"
        case .compress: return "Reduce PDF size with smart presets"
        case .create: return "Combine images and docs into PDF"
        case .edit: return "Add signatures, text, and markup"
        case .encrypt: return "Password protect your document"
        case .batch: return "Batch process multiple files"
        case .print: return "Print your documents easily"
        }
    }

    /// Indicates if tool is fully functional in v1.1
    public var isAvailable: Bool {
        switch self {
        case .organize, .compress, .create: return true
        default: return false
        }
    }
}
