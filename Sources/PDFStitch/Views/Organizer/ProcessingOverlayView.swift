import SwiftUI

/// Modal overlay displayed during background file loading or PDF export
struct ProcessingOverlayView: View {
    let statusMessage: String
    let current: Int
    let total: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ProgressView()
                    .scaleEffect(1.2)

                Text(statusMessage)
                    .font(.headline)

                if total > 0 {
                    Text("\(current) / \(total)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(28)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .windowBackgroundColor)))
            .shadow(radius: 10)
        }
    }
}
