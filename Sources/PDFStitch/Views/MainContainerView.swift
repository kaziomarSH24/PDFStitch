import SwiftUI

/// Root container view switching between the Dashboard, PDF Reader, and Page Organizer
public struct MainContainerView: View {
    @StateObject private var dashboardVM = DashboardViewModel()
    @StateObject private var organizerVM = OrganizerViewModel()

    public var body: some View {
        Group {
            switch dashboardVM.mode {
            case .dashboard:
                HStack(spacing: 0) {
                    SidebarView(dashboardVM: dashboardVM, organizerVM: organizerVM)
                    Divider()
                    DashboardView(dashboardVM: dashboardVM, organizerVM: organizerVM)
                }

            case .reader(let document, let fileURL):
                PDFReaderView(
                    document: document,
                    fileURL: fileURL,
                    onBackToDashboard: { dashboardVM.returnToDashboard() },
                    onOrganize: {
                        organizerVM.items.removeAll()
                        dashboardVM.launchOrganizer(with: [fileURL], organizerVM: organizerVM)
                    },
                    onCompress: {
                        organizerVM.items.removeAll()
                        organizerVM.selectedPreset = .maxCompress
                        dashboardVM.launchOrganizer(with: [fileURL], organizerVM: organizerVM)
                    }
                )

            case .organizer:
                OrganizerView(organizerVM: organizerVM) {
                    dashboardVM.returnToDashboard()
                }
            }
        }
        .frame(minWidth: 880, minHeight: 620)
    }
}
