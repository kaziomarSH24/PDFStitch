import SwiftUI

/// Handles drag-and-drop reordering of page cards within the grid
struct ReorderDropDelegate: DropDelegate {
    let currentItem: PageItem
    @Binding var items: [PageItem]
    @Binding var draggedItem: PageItem?

    func dropEntered(info: DropInfo) {
        guard let dragged = draggedItem,
              dragged != currentItem,
              let fromIdx = items.firstIndex(of: dragged),
              let toIdx = items.firstIndex(of: currentItem) else { return }

        withAnimation(.default) {
            items.move(fromOffsets: IndexSet(integer: fromIdx), toOffset: toIdx > fromIdx ? toIdx + 1 : toIdx)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
