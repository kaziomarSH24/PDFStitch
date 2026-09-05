import SwiftUI

/// Centralized Design System & Theme for PDFStitch
struct AppTheme {
    // MARK: - Colors
    struct Colors {
        static let primary = Color.blue
        static let background = Color(NSColor.windowBackgroundColor)
        static let cardBackground = Color(NSColor.controlBackgroundColor).opacity(0.8)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let border = Color.gray.opacity(0.2)
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
    }
    
    // MARK: - Fonts
    struct Fonts {
        static let heroTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let title = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 14, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
    }
    
    // MARK: - Metrics (Sizes, Radii)
    struct Metrics {
        static let cornerRadiusStandard: CGFloat = 12
        static let cornerRadiusLarge: CGFloat = 16
        static let paddingStandard: CGFloat = 16
        static let paddingSmall: CGFloat = 8
        static let iconSize: CGFloat = 24
    }
}
