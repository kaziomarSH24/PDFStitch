import SwiftUI

/// Popover providing custom DPI/Quality sliders with a live visual size progress bar
struct CustomCompressionPopoverView: View {
    @ObservedObject var organizerVM: OrganizerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text("Custom Compression")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button("Reset") {
                    organizerVM.customDPI = 110.0
                    organizerVM.customQuality = 48.0
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }

            Divider()

            // 1. DPI Slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Resolution (DPI):")
                        .font(.caption)
                    Spacer()
                    Text("\(Int(organizerVM.customDPI)) DPI")
                        .font(.caption.bold())
                        .foregroundColor(.accentColor)
                }
                Slider(value: $organizerVM.customDPI, in: 60...250, step: 5)
            }

            // 2. JPEG Quality Slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Image Quality:")
                        .font(.caption)
                    Spacer()
                    Text("\(Int(organizerVM.customQuality))%")
                        .font(.caption.bold())
                        .foregroundColor(.accentColor)
                }
                Slider(value: $organizerVM.customQuality, in: 15...90, step: 5)
            }

            Divider()

            // 3. Live Estimated Size Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Estimated PDF Size:")
                        .font(.caption.bold())
                    Spacer()
                    Text(String(format: "~%.1f MB", estimatedMB))
                        .font(.caption.bold())
                        .foregroundColor(gaugeColor)
                }

                // Visual Progress Bar (normalized to a 15 MB scale)
                ProgressView(value: min(1.0, max(0.02, estimatedMB / 15.0)))
                    .tint(gaugeColor)

                HStack {
                    Text(statusLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(gaugeColor)
                    Spacer()
                    Text("\(organizerVM.items.count) Pages")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor)))
        }
        .padding(14)
        .frame(width: 260)
    }

    // MARK: - Computed Properties
    private var estimatedMB: Double {
        organizerVM.estimatedMB(dpi: organizerVM.customDPI, quality: organizerVM.customQuality)
    }

    private var gaugeColor: Color {
        if estimatedMB <= 5.0 { return .green }
        if estimatedMB <= 9.0 { return .blue }
        if estimatedMB <= 15.0 { return .orange }
        return .red
    }

    private var statusLabel: String {
        if estimatedMB <= 5.0 { return "🟢 Very Small" }
        if estimatedMB <= 9.0 { return "🔵 Recommended for Upload (< 9 MB)" }
        if estimatedMB <= 15.0 { return "🟠 High Quality (> 9 MB)" }
        return "🔴 Very Heavy"
    }
}
