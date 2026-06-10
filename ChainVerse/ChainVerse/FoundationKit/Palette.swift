import SwiftUI
import UIKit

// The forge palette: black iron, bronze, gold, starlight. Drives every tier's look.
enum Palette {
    static let voidBase = Color(red: 0.05, green: 0.06, blue: 0.09)
    static let voidDeep = Color(red: 0.02, green: 0.02, blue: 0.05)
    static let ember = Color(red: 0.98, green: 0.58, blue: 0.18)
    static let ink = Color(red: 0.78, green: 0.82, blue: 0.92)
    static let faint = Color(red: 0.50, green: 0.55, blue: 0.66)

    // A chain's own accent, derived once from its title so it stays stable.
    static func accent(forSeed seed: Int) -> Color {
        let hue = Double(abs(seed) % 360) / 360.0
        return Color(hue: hue, saturation: 0.62, brightness: 0.92)
    }

    // Soft glassy fill behind cards and panels.
    static let panel = Color.white.opacity(0.05)
    static let panelEdge = Color.white.opacity(0.12)
}

extension Color {
    // Two-stop metal sheen used on links and badges.
    func sheen(_ lighter: Double = 0.22) -> LinearGradient {
        LinearGradient(
            colors: [self.opacity(0.55), self, self.lighten(lighter)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func lighten(_ amount: Double) -> Color {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: Double(h), saturation: Double(s) * 0.85, brightness: min(1, Double(b) + amount))
    }
}
