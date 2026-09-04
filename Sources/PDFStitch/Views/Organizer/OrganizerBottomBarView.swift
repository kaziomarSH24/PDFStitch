import SwiftUI

/// Bottom status bar showing document stats and the primary Export button
struct OrganizerBottomBarView: View {
    @ObservedObject var organizerVM: OrganizerViewModel

    var body: some View {
        HStack {
            // Stats summary
            VStack(alignment: .leading, spacing: 2) {
                Text("Total: \(organizerVM.items.count) Pages")
                    .font(.system(size: 13, weight: .semibold))

                Text(estimatedSizeSummary)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Merge & Export button
            Button(action: { organizerVM.savePDF() }) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.badge.arrow.up.fill")
                    Text("Merge & Export PDF")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(organizerVM.items.isEmpty || organizerVM.isProcessing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var estimatedSizeSummary: String {
        guard !organizerVM.items.isEmpty else { return "Estimated Size: 0 MB" }
        let totalMB = organizerVM.currentEstimatedMB
        let modeName = organizerVM.useCustomSettings ? "Custom \(Int(organizerVM.customDPI)) DPI" : organizerVM.selectedPreset.rawValue
        return String(format: "Est. Size: ~%.1f MB (%@ | %@)", totalMB, modeName, organizerVM.selectedPageSize.rawValue)
    }
}
