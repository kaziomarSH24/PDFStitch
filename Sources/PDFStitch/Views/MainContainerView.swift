import SwiftUI

/// Root container view switching between the Dashboard and individual tool views
public struct MainContainerView: View {
    @StateObject private var dashboardVM = DashboardViewModel()
    @StateObject private var organizerVM = OrganizerViewModel()

    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            if dashboardVM.activeTool == nil {
                // Dashboard layout: Left Sidebar + Popular Tools & Recents
                SidebarView(dashboardVM: dashboardVM, organizerVM: organizerVM)
                Divider()
                DashboardView(dashboardVM: dashboardVM, organizerVM: organizerVM)
            } else {
                // Active Tool layout (e.g. Organizer)
                OrganizerView(organizerVM: organizerVM) {
                    dashboardVM.returnToDashboard()
                }
            }
        }
        .frame(minWidth: 860, minHeight: 620)
    }
}
