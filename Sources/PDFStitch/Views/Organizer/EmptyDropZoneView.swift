import SwiftUI

/// Landing view shown when no documents or images have been imported yet
struct EmptyDropZoneView: View {
    let onChooseFiles: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.doc.fill")
                .font(.system(size: 52))
                .foregroundColor(.accentColor.opacity(0.8))

            Text("Drag & Drop Images or PDFs Here")
                .font(.system(size: 18, weight: .bold))

            Text("Supports JPEG, PNG, HEIC, TIFF and multi-page PDFs.\nPages can be rearranged by dragging or clicking page numbers.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onChooseFiles) {
                Label("Choose Files...", systemImage: "plus.circle")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
