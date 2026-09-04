import SwiftUI

/// Reusable card component for each Popular Tool on the Dashboard
struct ToolCardView: View {
    let tool: AppTool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Icon
                    Image(systemName: tool.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                        .frame(width: 36, height: 36)
                        .background(iconColor.opacity(0.15))
                        .cornerRadius(8)

                    Spacer()

                    if tool == .organize || tool == .compress {
                        Text("Active")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.green.opacity(0.2)))
                            .foregroundColor(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(tool.rawValue)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    Text(tool.subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(14)
            .frame(width: 200, height: 115)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .controlBackgroundColor)))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isHovered ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(isHovered ? 0.2 : 0.05), radius: isHovered ? 4 : 2, y: 1)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    private var iconColor: Color {
        switch tool {
        case .organize: return .orange
        case .compress: return .purple
        case .create: return .green
        case .edit: return .yellow
        case .encrypt: return .blue
        case .batch: return .cyan
        case .print: return .indigo
        }
    }
}
