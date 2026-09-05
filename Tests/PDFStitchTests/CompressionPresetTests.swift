import XCTest
@testable import PDFStitch

final class CompressionPresetTests: XCTestCase {

    func testBalancedPresetValues() throws {
        // Given
        let preset = CompressionPreset.balanced
        
        // Then
        XCTAssertEqual(preset.dpi, 110.0, "Balanced preset DPI should be 110.0 for optimal legibility.")
        XCTAssertEqual(preset.jpegQuality, 0.48, "Balanced preset JPEG quality should be 0.48.")
    }
    
    func testMaxCompressPresetValues() throws {
        let preset = CompressionPreset.maxCompress
        XCTAssertEqual(preset.dpi, 85.0)
        XCTAssertEqual(preset.jpegQuality, 0.30)
    }
    
    func testHighQualityPresetValues() throws {
        let preset = CompressionPreset.highQuality
        XCTAssertEqual(preset.dpi, 150.0)
        XCTAssertEqual(preset.jpegQuality, 0.70)
    }
    
    func testOriginalPresetValues() throws {
        let preset = CompressionPreset.original
        XCTAssertEqual(preset.dpi, 300.0)
        XCTAssertEqual(preset.jpegQuality, 0.95)
    }
}
