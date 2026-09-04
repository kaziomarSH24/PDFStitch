import SwiftUI

/// Left sidebar matching reference design with primary red action buttons
struct SidebarView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    @ObservedObject var organizerVM: OrganizerViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Primary Open PDF Button (Red)
            Button(action: { dashboardVM.promptOpenPDF(organizerVM: organizerVM) }) {
                HStack {
                    Image(systemName: "folder.fill")
                    Text("Open PDF")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.red)
            .controlSize(.large)

            // Create PDF Button
            Button(action: {
                dashboardVM.openTool(.organize)
                organizerVM.items.removeAll()
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Create PDF")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)

            Spacer()

            // App Brand Info at bottom
            HStack(spacing: 8) {
                Image(systemName: "doc.on.doc.fill")
                    .foregroundColor(.secondary)
                Text("PDF Stitch v1.1")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
        }
        .padding(14)
        .frame(width: 170)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
