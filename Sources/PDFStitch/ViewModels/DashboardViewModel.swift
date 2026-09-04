import SwiftUI
import AppKit

/// ViewModel managing navigation between Dashboard and active tools
@MainActor
public class DashboardViewModel: ObservableObject {
    /// The currently active tool screen (nil indicates user is on the Dashboard)
    @Published public var activeTool: AppTool? = nil

    /// Recent documents opened or generated
    @Published public var recentFiles: [URL] = []

    public init() {}

    /// Opens a specific tool from the Dashboard
    public func openTool(_ tool: AppTool) {
        self.activeTool = tool
    }

    /// Returns to the main Dashboard view
    public func returnToDashboard() {
        self.activeTool = nil
    }

    /// Prompts user to choose a PDF file and opens it directly in the Organizer
    public func promptOpenPDF(organizerVM: OrganizerViewModel) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.pdf, .jpeg, .png, .heic, .tiff]
        if panel.runModal() == .OK {
            self.activeTool = .organize
            organizerVM.loadURLs(panel.urls)
        }
    }
}
