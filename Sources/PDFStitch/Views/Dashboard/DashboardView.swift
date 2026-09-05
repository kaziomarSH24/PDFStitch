import SwiftUI

/// Main content area of the Dashboard displaying Popular Tools and Recents with modern styling
struct DashboardView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    @ObservedObject var organizerVM: OrganizerViewModel

    private let toolColumns = [
        GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Section 1: Popular Tools
                VStack(alignment: .leading, spacing: 12) {
                    Text("Popular Tools")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    LazyVGrid(columns: toolColumns, spacing: 14) {
                        ForEach(AppTool.allCases) { tool in
                            ToolCardView(tool: tool) {
                                handleToolClick(tool)
                            }
                        }
                    }
                }

                Divider().opacity(0.5)

                // Section 2: Recents
                RecentsView(dashboardVM: dashboardVM)
            }
            .padding(24)
        }
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
    }

    private func handleToolClick(_ tool: AppTool) {
        switch tool {
        case .organize:
            dashboardVM.launchOrganizer(organizerVM: organizerVM)
        case .compress:
            organizerVM.selectedPreset = .maxCompress
            dashboardVM.launchOrganizer(organizerVM: organizerVM)
        case .create:
            organizerVM.items.removeAll()
            dashboardVM.launchOrganizer(organizerVM: organizerVM)
        case .print:
            dashboardVM.promptOpenPDF()
        default:
            dashboardVM.launchOrganizer(organizerVM: organizerVM)
        }
    }
}
