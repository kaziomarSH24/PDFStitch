import SwiftUI

/// Main container view for the Organizer tool (reordering grid, sizing, and export)
struct OrganizerView: View {
    @ObservedObject var organizerVM: OrganizerViewModel
    let onBackToDashboard: () -> Void

    @State private var isTargetedForDrop = false

    private let columns = [GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 16)]

    var body: some View {
        VStack(spacing: 0) {
            // Top Toolbar
            OrganizerToolbarView(organizerVM: organizerVM, onBackToDashboard: onBackToDashboard)

            Divider()

            // Main Grid or Drop Zone
            ZStack {
                Color(nsColor: .underPageBackgroundColor).ignoresSafeArea()

                if organizerVM.items.isEmpty {
                    EmptyDropZoneView(onChooseFiles: { organizerVM.openFilePicker() })
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(organizerVM.items.enumerated()), id: \.element.id) { index, item in
                                PageCardView(
                                    item: item,
                                    pageIndex: index,
                                    totalPages: organizerVM.items.count,
                                    onRotate: { organizerVM.rotateItem(at: index) },
                                    onDelete: { organizerVM.removeItem(at: index) },
                                    onMoveTo: { targetIdx in organizerVM.moveItem(from: index, to: targetIdx) }
                                )
                                .onDrag {
                                    organizerVM.draggedItem = item
                                    return NSItemProvider(object: item.id.uuidString as NSString)
                                }
                                .onDrop(of: [.text], delegate: ReorderDropDelegate(
                                    currentItem: item,
                                    items: $organizerVM.items,
                                    draggedItem: $organizerVM.draggedItem
                                ))
                            }
                        }
                        .padding(20)
                    }
                }

                if isTargetedForDrop {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, dash: [8]))
                        .background(Color.accentColor.opacity(0.1))
                        .padding(14)
                }

                if organizerVM.isProcessing {
                    ProcessingOverlayView(
                        statusMessage: organizerVM.statusMessage,
                        current: organizerVM.progressCurrent,
                        total: organizerVM.progressTotal
                    )
                }
            }
            .onDrop(of: [.fileURL], isTargeted: $isTargetedForDrop) { providers in
                organizerVM.handleDroppedFiles(providers: providers)
                return true
            }

            Divider()

            // Bottom Action Bar
            OrganizerBottomBarView(organizerVM: organizerVM)
        }
        .alert("Export Complete!", isPresented: $organizerVM.showSuccessAlert) {
            Button("Open in Finder") {
                if let url = organizerVM.lastExportedURL { NSWorkspace.shared.activateFileViewerSelecting([url]) }
            }
            Button("OK", role: .cancel) {}
        }
    }
}
