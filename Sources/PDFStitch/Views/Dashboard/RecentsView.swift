import SwiftUI

/// Displays recent documents or a friendly empty placeholder
struct RecentsView: View {
    @ObservedObject var dashboardVM: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Recents")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                if !dashboardVM.recentFiles.isEmpty {
                    Button("Clear") { dashboardVM.recentFiles.removeAll() }
                        .font(.caption).buttonStyle(.plain).foregroundColor(.secondary)
                }
            }

            if dashboardVM.recentFiles.isEmpty {
                emptyPlaceholderView
            } else {
                recentFilesListView
            }
        }
    }

    private var emptyPlaceholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 38))
                .foregroundColor(.secondary.opacity(0.5))

            Text("Files you have recently viewed or worked with will be listed here")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Button(action: { dashboardVM.promptOpenPDF() }) {
                Text("Open PDF")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.red)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .controlBackgroundColor).opacity(0.4)))
    }

    private var recentFilesListView: some View {
        VStack(spacing: 6) {
            ForEach(dashboardVM.recentFiles, id: \.self) { url in
                Button(action: { dashboardVM.openPDF(at: url) }) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.fill").font(.system(size: 20)).foregroundColor(.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(url.lastPathComponent).font(.system(size: 12, weight: .medium)).foregroundColor(.primary)
                            Text(url.deletingLastPathComponent().path).font(.system(size: 10)).foregroundColor(.secondary).lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor)))
                }.buttonStyle(.plain)
            }
        }
    }
}
