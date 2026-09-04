import SwiftUI

/// Section displaying recently viewed or exported documents
struct RecentsView: View {
    @ObservedObject var dashboardVM: DashboardViewModel
    @ObservedObject var organizerVM: OrganizerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text("Recents")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.secondary)
            }

            // Empty state placeholder
            VStack(spacing: 12) {
                Image(systemName: "doc.badge.sparkles")
                    .font(.system(size: 44))
                    .foregroundColor(.secondary.opacity(0.6))

                Text("Files you have recently viewed or worked with will be listed here")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Button(action: { dashboardVM.promptOpenPDF(organizerVM: organizerVM) }) {
                    Text("Open PDF")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.red)
                .controlSize(.regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .controlBackgroundColor).opacity(0.5)))
        }
    }
}
