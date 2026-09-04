import SwiftUI

/// Main entry point for the PDFStitch macOS Application
@main
struct PDFStitchApp: App {
    var body: some Scene {
        WindowGroup {
            MainContainerView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
}
