import SwiftUI

// Adapted from
// https://www.hackingwithswift.com/example-code/uicolor/how-to-read-the-red-green-blue-and-alpha-color-components-from-a-uicolor
extension UIColor {
    var asColorRGBA: ColorRGBA {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        return ColorRGBA(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
    }
}
