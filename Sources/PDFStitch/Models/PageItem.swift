import Foundation
import AppKit

/// Represents the origin type of a page (image or page from an existing PDF)
public enum SourceType: Equatable {
    case image
    case pdfPage(pageIndex: Int, totalPages: Int)
}

/// Data model representing an individual page in the document grid
public struct PageItem: Identifiable, Equatable {
    public let id: UUID
    public let sourceURL: URL
    public let sourceType: SourceType
    public var title: String
    public var rotationDegrees: Int
    public var thumbnail: NSImage?
    public var originalSize: CGSize
    public var fileSizeBytes: Int64

    public init(
        id: UUID = UUID(),
        sourceURL: URL,
        sourceType: SourceType,
        title: String,
        rotationDegrees: Int = 0,
        thumbnail: NSImage? = nil,
        originalSize: CGSize = .zero,
        fileSizeBytes: Int64 = 0
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.sourceType = sourceType
        self.title = title
        self.rotationDegrees = rotationDegrees
        self.thumbnail = thumbnail
        self.originalSize = originalSize
        self.fileSizeBytes = fileSizeBytes
    }

    public static func == (lhs: PageItem, rhs: PageItem) -> Bool {
        lhs.id == rhs.id && lhs.rotationDegrees == rhs.rotationDegrees
    }
}
