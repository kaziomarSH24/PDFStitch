import Foundation
import PDFKit

/// Navigation state of the application
public enum AppMode: Equatable {
    case dashboard
    case reader(document: PDFDocument, fileURL: URL)
    case organizer

    public static func == (lhs: AppMode, rhs: AppMode) -> Bool {
        switch (lhs, rhs) {
        case (.dashboard, .dashboard), (.organizer, .organizer):
            return true
        case (.reader(_, let url1), .reader(_, let url2)):
            return url1 == url2
        default:
            return false
        }
    }
}
