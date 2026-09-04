import SwiftUI

/// Top toolbar for the Organizer screen with import, page sizing, and compression controls
struct OrganizerToolbarView: View {
    @ObservedObject var organizerVM: OrganizerViewModel
    let onBackToDashboard: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Back to Dashboard button
            Button(action: onBackToDashboard) {
                Label("Dashboard", systemImage: "chevron.left")
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)

            // Add Files button
            Button(action: { organizerVM.openFilePicker() }) {
                Label("Add Files", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)

            if !organizerVM.items.isEmpty {
                Button(action: { organizerVM.items.removeAll() }) {
                    Label("Clear All", systemImage: "trash")
                }.buttonStyle(.bordered)
            }

            Spacer()

            // Page Size Selector
            HStack(spacing: 4) {
                Text("Size:").font(.caption).foregroundColor(.secondary)
                Picker("", selection: $organizerVM.selectedPageSize) {
                    ForEach(PageSizeMode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .frame(width: 130)
            }

            // Quality Preset Selector
            HStack(spacing: 4) {
                Text("Quality:").font(.caption).foregroundColor(.secondary)
                Picker("", selection: $organizerVM.selectedPreset) {
                    ForEach(CompressionPreset.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .frame(width: 155)

                Toggle("Custom", isOn: $organizerVM.useCustomSettings)
                    .toggleStyle(.checkbox)
                    .font(.caption)
            }

            // Custom Sliders if enabled
            if organizerVM.useCustomSettings {
                customSlidersView
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var customSlidersView: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text("DPI: \(Int(organizerVM.customDPI))").font(.system(size: 9)).foregroundColor(.secondary)
                Slider(value: $organizerVM.customDPI, in: 50...300, step: 5).frame(width: 75)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("Qual: \(Int(organizerVM.customQuality))%").font(.system(size: 9)).foregroundColor(.secondary)
                Slider(value: $organizerVM.customQuality, in: 10...100, step: 5).frame(width: 75)
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color(nsColor: .controlBackgroundColor)))
    }
}
