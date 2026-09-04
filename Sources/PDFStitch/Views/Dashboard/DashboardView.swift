import SwiftUI

/// Main content area of the Dashboard displaying Popular Tools and Recents
struct DashboardView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    @ObservedObject var organizerVM: OrganizerViewModel

    private let toolColumns = [
        GridItem(.adaptive(minimum: 190, maximum: 220), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Section 1: Popular Tools
                VStack(alignment: .leading, spacing: 14) {
                    Text("Popular Tools")
                        .font(.system(size: 18, weight: .bold))

                    LazyVGrid(columns: toolColumns, spacing: 14) {
                        ForEach(AppTool.allCases) { tool in
                            ToolCardView(tool: tool) {
                                handleToolClick(tool)
                            }
                        }
                    }
                }

                Divider()

                // Section 2: Recents
                RecentsView(dashboardVM: dashboardVM, organizerVM: organizerVM)
            }
            .padding(24)
        }
        .background(Color(nsColor: .underPageBackgroundColor))
    }

    private func handleToolClick(_ tool: AppTool) {
        dashboardVM.openTool(tool)
        if tool == .compress {
            organizerVM.selectedPreset = .maxCompress
        } else if tool == .organize {
            organizerVM.selectedPreset = .balanced
        }
    }
}
