import SwiftUI

/// Top toolbar for the Organizer screen with clean layout that never wraps or breaks
struct OrganizerToolbarView: View {
    @ObservedObject var organizerVM: OrganizerViewModel
    let onBackToDashboard: () -> Void

    @State private var showCustomPopover = false

    var body: some View {
        HStack(spacing: 12) {
            // Back to Dashboard
            Button(action: onBackToDashboard) {
                Label("Dashboard", systemImage: "chevron.left")
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .fixedSize()

            // Add Files
            Button(action: { organizerVM.openFilePicker() }) {
                Label("Add Files", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .fixedSize()

            if !organizerVM.items.isEmpty {
                Button(action: { organizerVM.items.removeAll() }) {
                    Label("Clear All", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .fixedSize()
            }

            Spacer(minLength: 12)

            // Page Size Selector
            HStack(spacing: 6) {
                Text("Size:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize()

                Picker("", selection: $organizerVM.selectedPageSize) {
                    ForEach(PageSizeMode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .frame(width: 145)
            }
            .fixedSize()

            // Quality Preset Selector
            HStack(spacing: 6) {
                Text("Quality:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize()

                Picker("", selection: $organizerVM.selectedPreset) {
                    ForEach(CompressionPreset.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .frame(width: 175)
                .disabled(organizerVM.useCustomSettings)

                // Custom Sliders Button with Popover
                Button(action: {
                    organizerVM.useCustomSettings.toggle()
                    if organizerVM.useCustomSettings { showCustomPopover = true }
                }) {
                    Label(organizerVM.useCustomSettings ? "Custom" : "Custom...", systemImage: "slider.horizontal.3")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(organizerVM.useCustomSettings ? Color.accentColor : Color.secondary)
                .popover(isPresented: $showCustomPopover) {
                    CustomCompressionPopoverView(organizerVM: organizerVM)
                }
                .fixedSize()
            }
            .fixedSize()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
