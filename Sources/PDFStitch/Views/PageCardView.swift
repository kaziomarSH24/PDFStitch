import SwiftUI

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
                // Thumbnail container
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(isHovered ? 0.25 : 0.1), radius: isHovered ? 6 : 3, y: 2)

                    if let thumb = item.thumbnail {
                        Image(nsImage: thumb)
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(.degrees(Double(item.rotationDegrees)))
                            .padding(6)
                    } else {
                        Image(systemName: "doc")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 150, height: 200)

                // Page Number Badge (Clickable to change position)
                Button(action: {
                    targetPageText = "\(pageIndex + 1)"
                    showMovePopover = true
                }) {
                    Text("\(pageIndex + 1)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.accentColor))
                        .shadow(radius: 2)
                }
                .buttonStyle(.plain)
                .offset(x: 8, y: 8)
                .help("Click to move to a specific page number")
                .popover(isPresented: $showMovePopover) {
                    VStack(spacing: 10) {
                        Text("Move to Page:")
                            .font(.system(size: 12, weight: .bold))

                        HStack(spacing: 6) {
                            TextField("Page", text: $targetPageText)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 60)
                                .multilineTextAlignment(.center)
                                .onSubmit {
                                    applyMove()
                                }

                            Text("/ \(totalPages)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)

                            Button("Go") {
                                applyMove()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }

                        Divider()

                        HStack(spacing: 8) {
                            Button("First (Page 1)") {
                                onMoveTo(0)
                                showMovePopover = false
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                            Button("Last (\(totalPages))") {
                                onMoveTo(totalPages - 1)
                                showMovePopover = false
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    .padding(12)
                    .frame(width: 200)
                }

                // Action buttons on top-right
                HStack(spacing: 4) {
                    // Rotate button
                    Button(action: onRotate) {
                        Image(systemName: "rotate.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Color(nsColor: .windowBackgroundColor).opacity(0.9)))
                            .shadow(radius: 1)
                    }
                    .buttonStyle(.plain)
                    .help("Rotate 90° Clockwise")

                    // Delete button
                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Color(nsColor: .windowBackgroundColor).opacity(0.9)))
                            .shadow(radius: 1)
                    }
                    .buttonStyle(.plain)
                    .help("Remove Page")
                }
                .offset(x: 96, y: 8)
                .opacity(isHovered ? 1.0 : 0.6)
            }

            // Title / filename
            Text(item.title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(width: 140)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isHovered ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button {
                onMoveTo(0)
            } label: {
                Label("Move to First (Page 1)", systemImage: "arrow.up.to.line")
            }

            Button {
                onMoveTo(totalPages - 1)
            } label: {
                Label("Move to Last (Page \(totalPages))", systemImage: "arrow.down.to.line")
            }

            if pageIndex > 0 {
                Button {
                    onMoveTo(pageIndex - 1)
                } label: {
                    Label("Move Left", systemImage: "arrow.left")
                }
            }

            if pageIndex < totalPages - 1 {
                Button {
                    onMoveTo(pageIndex + 1)
                } label: {
                    Label("Move Right", systemImage: "arrow.right")
                }
            }

            Divider()

            Button(action: onRotate) {
                Label("Rotate 90° Clockwise", systemImage: "rotate.right")
            }

            Divider()

            Button(role: .destructive, action: onDelete) {
                Label("Delete Page", systemImage: "trash")
            }
        }
    }

    private func applyMove() {
        if let target = Int(targetPageText.trimmingCharacters(in: .whitespacesAndNewlines)),
           target >= 1 && target <= totalPages {
            onMoveTo(target - 1)
            showMovePopover = false
        }
    }
}
