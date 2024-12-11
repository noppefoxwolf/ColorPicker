import XCTest
@testable import ColorPicker

final class ColorFormatterTests: XCTestCase {
    func testEncodeDecodeWithHash() {
        let string = "#123456"
        let color = ColorFormatter().color(from: string)!
        let string2 = ColorFormatter().string(from: color)
        XCTAssertEqual(string2, "123456")
    }
    
    func testEncodeDecode() {
        let string = "123456"
        let color = ColorFormatter().color(from: string)!
        let string2 = ColorFormatter().string(from: color)
        XCTAssertEqual(string2, "123456")
    }
}
