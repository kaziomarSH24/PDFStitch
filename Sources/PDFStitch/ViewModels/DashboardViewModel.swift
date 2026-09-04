import SwiftUI
import AppKit
import PDFKit

/// ViewModel managing top-level navigation: Dashboard, PDF Reader, or Page Organizer
@MainActor
public class DashboardViewModel: ObservableObject {
    /// Active application screen
    @Published public var mode: AppMode = .dashboard

    /// Recent documents opened or worked with
    @Published public var recentFiles: [URL] = []

    public init() {}

    /// Returns user to the main Dashboard screen
    public func returnToDashboard() {
        self.mode = .dashboard
    }

    /// Opens a PDF file directly into Reader view
    public func openPDF(at url: URL) {
        guard let doc = PDFDocument(url: url) else { return }
        self.mode = .reader(document: doc, fileURL: url)
        addRecent(url)
    }

    /// File picker to open and read a PDF
    public func promptOpenPDF() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.pdf]
        if panel.runModal() == .OK, let url = panel.url {
            openPDF(at: url)
        }
    }

    /// Launches the Organizer / Creator tool with optional preloaded files
    public func launchOrganizer(with urls: [URL] = [], organizerVM: OrganizerViewModel) {
        self.mode = .organizer
        if !urls.isEmpty {
            organizerVM.loadURLs(urls)
        }
    }

    /// Adds a file URL to the recent documents list
    public func addRecent(_ url: URL) {
        if let idx = recentFiles.firstIndex(of: url) {
            recentFiles.remove(at: idx)
        }
        recentFiles.insert(url, at: 0)
        if recentFiles.count > 10 {
            recentFiles.removeLast()
        }
    }
}
