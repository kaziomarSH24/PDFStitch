import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// ViewModel managing state, file picking, reordering, and export for the Organizer tool
@MainActor
public class OrganizerViewModel: ObservableObject {
    @Published public var items: [PageItem] = []
    @Published public var selectedPreset: CompressionPreset = .balanced
    @Published public var selectedPageSize: PageSizeMode = .a4Portrait
    @Published public var useCustomSettings: Bool = false
    @Published public var customDPI: Double = 110.0
    @Published public var customQuality: Double = 48.0

    @Published public var isProcessing: Bool = false
    @Published public var statusMessage: String = ""
    @Published public var progressCurrent: Int = 0
    @Published public var progressTotal: Int = 0

    @Published public var showSuccessAlert: Bool = false
    @Published public var lastExportedURL: URL? = nil
    @Published public var draggedItem: PageItem? = nil

    public init() {}

    // MARK: - Calibrated Size Estimation
    public func estimatedMB(dpi: Double, quality: Double) -> Double {
        guard !items.isEmpty else { return 0.0 }
        let scale = dpi / 72.0
        // Calibrated against real macOS PDFKit JPEG output with scanned receipts (175 KB base + 12 KB PDF overhead)
        let perPageKB = (scale * scale * 175.0 * (quality / 100.0)) + 12.0
        return (Double(items.count) * perPageKB) / 1024.0
    }

    public var currentEstimatedMB: Double {
        let dpi = useCustomSettings ? customDPI : selectedPreset.dpi
        let qual = useCustomSettings ? customQuality : (selectedPreset.jpegQuality * 100.0)
        return estimatedMB(dpi: dpi, quality: qual)
    }

    // MARK: - Page Actions
    public func rotateItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        items[index].rotationDegrees = (items[index].rotationDegrees + 90) % 360
    }

    public func removeItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }

    public func moveItem(from fromIdx: Int, to toIdx: Int) {
        guard items.indices.contains(fromIdx), items.indices.contains(toIdx), fromIdx != toIdx else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            let item = items.remove(at: fromIdx)
            items.insert(item, at: toIdx)
        }
    }

    // MARK: - File Import
    public func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.pdf, .jpeg, .png, .heic, .tiff, .webP]
        if panel.runModal() == .OK { loadURLs(panel.urls) }
    }

    public func handleDroppedFiles(providers: [NSItemProvider]) {
        var urls: [URL] = []
        let group = DispatchGroup()
        for p in providers {
            group.enter()
            _ = p.loadObject(ofClass: URL.self) { url, _ in
                if let url = url { urls.append(url) }
                group.leave()
            }
        }
        group.notify(queue: .main) { self.loadURLs(urls) }
    }

    public func loadURLs(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        isProcessing = true
        statusMessage = "Loading files..."
        Task {
            let loaded = await PDFProcessor.shared.loadItems(from: urls) { msg in
                Task { @MainActor in self.statusMessage = msg }
            }
            self.items.append(contentsOf: loaded)
            self.isProcessing = false
        }
    }

    // MARK: - Export
    public func savePDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "Merged_Document.pdf"
        if panel.runModal() == .OK, let url = panel.url {
            isProcessing = true
            progressTotal = items.count
            statusMessage = "Exporting PDF..."
            Task {
                do {
                    try await PDFProcessor.shared.exportPDF(
                        items: items, preset: selectedPreset, pageSizeMode: selectedPageSize,
                        customDPI: useCustomSettings ? CGFloat(customDPI) : nil,
                        customQuality: useCustomSettings ? CGFloat(customQuality / 100.0) : nil,
                        to: url
                    ) { cur, tot in
                        Task { @MainActor in self.progressCurrent = cur; self.progressTotal = tot }
                    }
                    self.isProcessing = false
                    self.lastExportedURL = url
                    self.showSuccessAlert = true
                } catch {
                    self.isProcessing = false
                }
            }
        }
    }
}
