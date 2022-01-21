import SwiftUI

extension UIColor {
    var asColorRGBA: ColorRGBA {
        ColorRGBA(r: rgba.r, g: rgba.g, b: rgba.b, a: rgba.a)
    }

    var getAlpha: Double {
        rgba.a
    }

    // Adapted from
    // https://www.hackingwithswift.com/example-code/uicolor/how-to-read-the-r-green-blue-and-alpha-color-components-from-a-uicolor
    var rgba: (r: Double, g: Double, b: Double, a: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}
