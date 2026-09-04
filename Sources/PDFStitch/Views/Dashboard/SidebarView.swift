import SwiftUI

/// Left navigation sidebar with primary action buttons matching the reference design
struct SidebarView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    @ObservedObject var organizerVM: OrganizerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Primary Open PDF Button (Red)
            Button(action: { dashboardVM.promptOpenPDF() }) {
                HStack(spacing: 8) {
                    Image(systemName: "folder.fill")
                    Text("Open PDF")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.red)
            .controlSize(.large)

            // Create / Merge PDF Button
            Button(action: {
                organizerVM.items.removeAll()
                dashboardVM.launchOrganizer(organizerVM: organizerVM)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                    Text("Create PDF")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)

            Divider().padding(.vertical, 4)

            // Navigation Links
            VStack(alignment: .leading, spacing: 8) {
                Label("Home", systemImage: "house.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 12, weight: .semibold))

                Button(action: { dashboardVM.promptOpenPDF() }) {
                    Label("View Document", systemImage: "eye.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                }.buttonStyle(.plain)

                Button(action: { dashboardVM.launchOrganizer(organizerVM: organizerVM) }) {
                    Label("Organize Pages", systemImage: "square.stack.3d.up.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                }.buttonStyle(.plain)
            }
            .padding(.horizontal, 4)

            Spacer()

            // Footer info
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text("PDF Stitch v1.1")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .frame(width: 190)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
