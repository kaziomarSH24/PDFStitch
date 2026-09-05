import SwiftUI

/// Displays recent documents with modern Apple-grade cards or a friendly placeholder
struct RecentsView: View {
    @ObservedObject var dashboardVM: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text("Recents")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                if !dashboardVM.recentFiles.isEmpty {
                    Button("Clear History") { dashboardVM.recentFiles.removeAll() }
                        .font(.caption)
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
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
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 64, height: 64)

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary.opacity(0.7))
            }

            Text("Files you have recently viewed or worked with will appear here")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Button(action: { dashboardVM.promptOpenPDF() }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Open PDF")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.red)
            .controlSize(.regular)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var recentFilesListView: some View {
        VStack(spacing: 8) {
            ForEach(dashboardVM.recentFiles, id: \.self) { url in
                RecentFileRow(url: url) {
                    dashboardVM.openPDF(at: url)
                }
            }
        }
    }
}

/// Row component for an individual recent file
struct RecentFileRow: View {
    let url: URL
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red.opacity(0.9))

                VStack(alignment: .leading, spacing: 2) {
                    Text(url.lastPathComponent)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(url.deletingLastPathComponent().path)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isHovered ? .accentColor : .clear)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 0.8 : 0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isHovered ? Color.accentColor.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
