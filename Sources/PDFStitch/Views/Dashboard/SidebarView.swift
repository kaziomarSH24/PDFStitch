import SwiftUI

/// Left navigation sidebar with modern frosted glass aesthetic and primary action buttons
struct SidebarView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    @ObservedObject var organizerVM: OrganizerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Primary Open PDF Button (Vibrant Red Gradient)
            Button(action: { dashboardVM.promptOpenPDF() }) {
                HStack(spacing: 8) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("Open PDF")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [Color(red: 0.95, green: 0.22, blue: 0.22), Color(red: 0.8, green: 0.1, blue: 0.1)], startPoint: .top, endPoint: .bottom))
                        .shadow(color: Color.red.opacity(0.35), radius: 5, y: 2)
                )
            }
            .buttonStyle(.plain)

            // Secondary Create / Merge PDF Button
            Button(action: {
                organizerVM.items.removeAll()
                dashboardVM.launchOrganizer(organizerVM: organizerVM)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Create PDF")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.1), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)

            Divider().padding(.vertical, 2).opacity(0.6)

            // Navigation Links
            VStack(alignment: .leading, spacing: 6) {
                sidebarLink(title: "Home", icon: "house.fill", isActive: true) {}
                sidebarLink(title: "View Document", icon: "eye.fill", isActive: false) { dashboardVM.promptOpenPDF() }
                sidebarLink(title: "Organize Pages", icon: "square.stack.3d.up.fill", isActive: false) {
                    dashboardVM.launchOrganizer(organizerVM: organizerVM)
                }
            }

            Spacer()

            // Support Creator Button (Buy Me a Coffee)
            Button(action: {
                if let url = URL(string: "https://gumroad.com") { NSWorkspace.shared.open(url) }
            }) {
                HStack(spacing: 6) {
                    Text("☕")
                    Text("Support Creator")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.orange.opacity(0.08)))
            }
            .buttonStyle(.plain)

            // Version info
            Text("PDF Stitch v1.2")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.7))
                .padding(.leading, 4)
        }
        .padding(16)
        .frame(width: 195)
        .background(.ultraThinMaterial)
    }

    private func sidebarLink(title: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(isActive ? .accentColor : .secondary)
                Text(title)
                    .font(.system(size: 12, weight: isActive ? .bold : .regular, design: .rounded))
                    .foregroundColor(isActive ? .primary : .secondary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isActive ? RoundedRectangle(cornerRadius: 6).fill(Color.accentColor.opacity(0.15)) : nil)
        }
        .buttonStyle(.plain)
    }
}
