import Foundation

// Custom color struct which is codable
struct ColorRGBA: Codable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    static func white() -> ColorRGBA {
        ColorRGBA(r: 1, g: 1, b: 1, a: 1)
    }
}
