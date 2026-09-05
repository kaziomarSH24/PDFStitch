import SwiftUI

/// Modern landing drop zone with frosted glass container and supported format chips
struct EmptyDropZoneView: View {
    let onChooseFiles: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Glowing Floating Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.2), Color.cyan.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "arrow.down.doc.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor, Color.cyan],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("Drag & Drop Images or PDFs Here")
                    .font(.system(size: 19, weight: .bold, design: .rounded))

                Text("Combine multiple pages, rearrange order, and optimize size effortlessly.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Supported Format Chips
            HStack(spacing: 6) {
                formatChip("PDF")
                formatChip("JPEG")
                formatChip("PNG")
                formatChip("HEIC")
                formatChip("TIFF")
            }
            .padding(.top, 2)

            // Primary Choose Files Button
            Button(action: onChooseFiles) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Choose Files...")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 6)
        }
        .padding(40)
        .frame(maxWidth: 520)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.3), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6])
                )
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formatChip(_ name: String) -> some View {
        Text(name)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.secondary.opacity(0.12)))
            .foregroundColor(.secondary)
    }
}
