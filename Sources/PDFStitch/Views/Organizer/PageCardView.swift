import SwiftUI

/// Thumbnail card representing an individual page with reordering, rotate, and delete controls
struct PageCardView: View {
    let item: PageItem
    let pageIndex: Int
    let totalPages: Int
    let onRotate: () -> Void
    let onDelete: () -> Void
    let onMoveTo: (Int) -> Void

    @State private var isHovered = false
    @State private var showMovePopover = false
    @State private var targetPageText = ""

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topLeading) {
                // Card Thumbnail Surface
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(isHovered ? 0.25 : 0.08), radius: isHovered ? 5 : 2, y: 1)

                    if let thumb = item.thumbnail {
                        Image(nsImage: thumb)
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(.degrees(Double(item.rotationDegrees)))
                            .padding(6)
                    } else {
                        Image(systemName: "doc")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 145, height: 195)

                // Page Number Badge (Click to jump to page)
                pageBadgeButton
                    .offset(x: 8, y: 8)

                // Quick Action Buttons (Rotate & Delete)
                actionButtons
                    .offset(x: 92, y: 8)
                    .opacity(isHovered ? 1.0 : 0.6)
            }

            // Filename label
            Text(item.title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(width: 135)
        }
        .padding(6)
        .onHover { isHovered = $0 }
        .contextMenu { contextMenuItems }
    }

    // MARK: - Subviews
    private var pageBadgeButton: some View {
        Button(action: { targetPageText = "\(pageIndex + 1)"; showMovePopover = true }) {
            Text("\(pageIndex + 1)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.accentColor))
                .shadow(radius: 2)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showMovePopover) { popoverContent }
    }

    private var actionButtons: some View {
        HStack(spacing: 4) {
            Button(action: onRotate) {
                Image(systemName: "rotate.right").font(.system(size: 10, weight: .bold))
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color(nsColor: .windowBackgroundColor)))
            }.buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "xmark").font(.system(size: 10, weight: .bold)).foregroundColor(.red)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color(nsColor: .windowBackgroundColor)))
            }.buttonStyle(.plain)
        }
    }

    private var popoverContent: some View {
        VStack(spacing: 8) {
            Text("Move to Page:").font(.caption.bold())
            HStack {
                TextField("", text: $targetPageText).frame(width: 50).textFieldStyle(.roundedBorder)
                    .onSubmit { applyMove() }
                Text("/ \(totalPages)").font(.caption).foregroundColor(.secondary)
                Button("Go") { applyMove() }.controlSize(.small)
            }
            HStack(spacing: 6) {
                Button("First") { onMoveTo(0); showMovePopover = false }.controlSize(.small)
                Button("Last") { onMoveTo(totalPages - 1); showMovePopover = false }.controlSize(.small)
            }
        }.padding(10)
    }

    private var contextMenuItems: some View {
        Group {
            Button("Move to First (Page 1)") { onMoveTo(0) }
            Button("Move to Last (Page \(totalPages))") { onMoveTo(totalPages - 1) }
            Divider()
            Button("Rotate 90° Clockwise", action: onRotate)
            Button("Delete Page", role: .destructive, action: onDelete)
        }
    }

    private func applyMove() {
        if let target = Int(targetPageText), target >= 1 && target <= totalPages {
            onMoveTo(target - 1)
            showMovePopover = false
        }
    }
}
