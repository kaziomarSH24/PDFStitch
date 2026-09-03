import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var items: [PageItem] = []
    @State private var selectedPreset: CompressionPreset = .balanced
    @State private var selectedPageSize: PageSizeMode = .a4Portrait
    @State private var useCustomSettings = false
    @State private var customDPI: Double = 85.0
    @State private var customQuality: Double = 25.0

    @State private var isProcessing = false
    @State private var statusMessage = ""
    @State private var progressCurrent = 0
    @State private var progressTotal = 0

    @State private var isTargetedForDrop = false
    @State private var draggedItem: PageItem?
    @State private var lastExportedURL: URL?
    @State private var showSuccessAlert = false

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top Toolbar
            topBarView
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Main Content: Drop zone or Grid
            ZStack {
                Color(nsColor: .underPageBackgroundColor)
                    .ignoresSafeArea()

                if items.isEmpty {
                    emptyDropZoneView
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                PageCardView(
                                    item: item,
                                    pageIndex: index,
                                    totalPages: items.count,
                                    onRotate: { rotateItem(at: index) },
                                    onDelete: { removeItem(at: index) },
                                    onMoveTo: { targetIndex in moveItem(from: index, to: targetIndex) }
                                )
                                .onDrag {
                                    self.draggedItem = item
                                    return NSItemProvider(object: item.id.uuidString as NSString)
                                }
                                .onDrop(of: [.text], delegate: ReorderDropDelegate(
                                    currentItem: item,
                                    items: $items,
                                    draggedItem: $draggedItem
                                ))
                            }
                        }
                        .padding(24)
                    }
                }

                // Drag and drop overlay
                if isTargetedForDrop {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, dash: [8]))
                        .background(Color.accentColor.opacity(0.1))
                        .padding(16)
                }

                // Processing modal overlay
                if isProcessing {
                    processingOverlayView
                }
            }
            .onDrop(of: [.fileURL], isTargeted: $isTargetedForDrop) { providers in
                handleDroppedFiles(providers: providers)
                return true
            }

            Divider()

            // Bottom Action Bar
            bottomBarView
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 800, minHeight: 600)
        .alert("Export Successful!", isPresented: $showSuccessAlert) {
            Button("Open in Finder") {
                if let url = lastExportedURL {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            if let url = lastExportedURL {
                Text("Saved to: \(url.lastPathComponent)")
            }
        }
    }

    // MARK: - Top Toolbar
    private var topBarView: some View {
        HStack(spacing: 16) {
            // Import buttons
            Button(action: openFilePicker) {
                Label("Add Files", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)

            if !items.isEmpty {
                Button(action: { items.removeAll() }) {
                    Label("Clear All", systemImage: "trash")
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            // Page Size Selector
            HStack(spacing: 6) {
                Text("Page Size:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Picker("", selection: $selectedPageSize) {
                    ForEach(PageSizeMode.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 140)
            }

            // Quality & Compression Selector
            HStack(spacing: 8) {
                Text("Quality:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Picker("", selection: $selectedPreset) {
                    ForEach(CompressionPreset.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 170)

                Toggle("Custom", isOn: $useCustomSettings)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))
            }

            if useCustomSettings {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DPI: \(Int(customDPI))")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Slider(value: $customDPI, in: 50...300, step: 5)
                            .frame(width: 90)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quality: \(Int(customQuality))%")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Slider(value: $customQuality, in: 10...100, step: 5)
                            .frame(width: 90)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color(nsColor: .controlBackgroundColor)))
            }
        }
    }

    // MARK: - Empty Drop Zone
    private var emptyDropZoneView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.doc.fill")
                .font(.system(size: 56))
                .foregroundColor(.accentColor.opacity(0.8))

            Text("Drag & Drop Images or PDFs Here")
                .font(.system(size: 20, weight: .bold))

            Text("Supports JPEG, PNG, HEIC, TIFF and multi-page PDFs.\nPages can be rearranged by dragging.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: openFilePicker) {
                Text("Choose Files...")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bottom Action Bar
    private var bottomBarView: some View {
        HStack {
            // Stats
            VStack(alignment: .leading, spacing: 2) {
                Text("Total: \(items.count) Pages")
                    .font(.system(size: 14, weight: .semibold))

                Text(estimatedSizeDescription)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Export Button
            Button(action: savePDF) {
                HStack {
                    Image(systemName: "doc.badge.arrow.up.fill")
                    Text("Merge & Export PDF")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(items.isEmpty || isProcessing)
        }
    }

    // Estimated file size calculation
    private var estimatedSizeDescription: String {
        guard !items.isEmpty else { return "Estimated Size: 0 MB" }
        let dpi = useCustomSettings ? customDPI : selectedPreset.dpi
        let quality = useCustomSettings ? (customQuality / 100.0) : selectedPreset.jpegQuality

        // Approximate calculation: per page ~ (dpi/72)^2 * 150KB * quality
        let scale = (dpi / 72.0)
        let perPageKB = max(30.0, scale * scale * 120.0 * quality)
        let totalMB = (Double(items.count) * perPageKB) / 1024.0

        if selectedPreset == .original && !useCustomSettings {
            return "Mode: Original Quality | Page Size: \(selectedPageSize.rawValue)"
        } else {
            return String(format: "Est. Size: ~%.1f MB (%@ | %@)", totalMB, selectedPreset.rawValue, selectedPageSize.rawValue)
        }
    }

    // MARK: - Processing Overlay
    private var processingOverlayView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.3)

                Text(statusMessage)
                    .font(.headline)

                if progressTotal > 0 {
                    Text("\(progressCurrent) / \(progressTotal)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(32)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(nsColor: .windowBackgroundColor)))
            .shadow(radius: 12)
        }
    }

    // MARK: - File Actions
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.pdf, .jpeg, .png, .heic, .tiff, .webP]

        if panel.runModal() == .OK {
            loadURLs(panel.urls)
        }
    }

    private func handleDroppedFiles(providers: [NSItemProvider]) {
        var droppedURLs: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    droppedURLs.append(url)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            loadURLs(droppedURLs)
        }
    }

    private func loadURLs(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        isProcessing = true
        statusMessage = "Loading pages..."

        Task {
            let loadedItems = await PDFProcessor.shared.loadItems(from: urls) { message in
                Task { @MainActor in
                    self.statusMessage = message
                }
            }

            await MainActor.run {
                self.items.append(contentsOf: loadedItems)
                self.isProcessing = false
            }
        }
    }

    private func rotateItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        items[index].rotationDegrees = (items[index].rotationDegrees + 90) % 360
    }

    private func removeItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }

    private func moveItem(from fromIndex: Int, to toIndex: Int) {
        guard items.indices.contains(fromIndex), items.indices.contains(toIndex), fromIndex != toIndex else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            let item = items.remove(at: fromIndex)
            items.insert(item, at: toIndex)
        }
    }

    // MARK: - Export Logic
    private func savePDF() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.nameFieldStringValue = "Merged_Document.pdf"

        if savePanel.runModal() == .OK, let targetURL = savePanel.url {
            isProcessing = true
            progressCurrent = 0
            progressTotal = items.count
            statusMessage = "Exporting PDF..."

            let currentItems = self.items
            let preset = self.selectedPreset
            let pageSizeMode = self.selectedPageSize
            let customDPI = self.useCustomSettings ? CGFloat(self.customDPI) : nil
            let customQuality = self.useCustomSettings ? CGFloat(self.customQuality / 100.0) : nil

            Task {
                do {
                    try await PDFProcessor.shared.exportPDF(
                        items: currentItems,
                        preset: preset,
                        pageSizeMode: pageSizeMode,
                        customDPI: customDPI,
                        customQuality: customQuality,
                        to: targetURL
                    ) { current, total in
                        Task { @MainActor in
                            self.progressCurrent = current
                            self.progressTotal = total
                            self.statusMessage = "Processing page \(current) of \(total)..."
                        }
                    }

                    await MainActor.run {
                        self.isProcessing = false
                        self.lastExportedURL = targetURL
                        self.showSuccessAlert = true
                    }
                } catch {
                    await MainActor.run {
                        self.isProcessing = false
                        let alert = NSAlert()
                        alert.messageText = "Export Failed"
                        alert.informativeText = error.localizedDescription
                        alert.alertStyle = .critical
                        alert.runModal()
                    }
                }
            }
        }
    }
}

// MARK: - Reorder Drop Delegate
struct ReorderDropDelegate: DropDelegate {
    let currentItem: PageItem
    @Binding var items: [PageItem]
    @Binding var draggedItem: PageItem?

    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem != currentItem,
              let fromIndex = items.firstIndex(of: draggedItem),
              let toIndex = items.firstIndex(of: currentItem) else {
            return
        }

        withAnimation(.default) {
            items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
