import SwiftUI

/// Reusable card component for each Popular Tool with modern Apple-grade glassmorphism
struct ToolCardView: View {
    let tool: AppTool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Tool Icon with Vibrant Dual-Tone Gradient
                    ZStack {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(iconGradient)
                            .frame(width: 36, height: 36)
                            .shadow(color: gradientLeadColor.opacity(0.4), radius: 4, y: 2)

                        Image(systemName: tool.iconName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    if tool.isAvailable {
                        Text("Active")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.green.opacity(0.2)))
                            .foregroundColor(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(tool.rawValue)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(tool.subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 0.9 : 0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(isHovered ? 0.35 : 0.12), .white.opacity(isHovered ? 0.1 : 0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(isHovered ? 0.22 : 0.05), radius: isHovered ? 8 : 3, y: isHovered ? 4 : 1)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    // MARK: - Gradient Helpers
    private var gradientLeadColor: Color {
        switch tool {
        case .organize: return Color.orange
        case .compress: return Color.purple
        case .create: return Color.green
        case .edit: return Color.yellow
        case .encrypt: return Color.blue
        case .batch: return Color.cyan
        case .print: return Color.indigo
        }
    }

    private var iconGradient: LinearGradient {
        switch tool {
        case .organize:
            return LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .compress:
            return LinearGradient(colors: [Color(red: 0.65, green: 0.25, blue: 0.95), Color(red: 0.35, green: 0.15, blue: 0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .create:
            return LinearGradient(colors: [Color(red: 0.15, green: 0.85, blue: 0.55), Color(red: 0.05, green: 0.65, blue: 0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .edit:
            return LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .encrypt:
            return LinearGradient(colors: [Color.blue, Color(red: 0.1, green: 0.2, blue: 0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .batch:
            return LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .print:
            return LinearGradient(colors: [Color.indigo, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
