import SwiftUI

// Reads the live width so phones, plus-size, and iPad compat all breathe correctly.
// Named Expanse (not Span) to avoid the stdlib's Span<Element>.
struct Expanse {
    let width: CGFloat
    let roomy: Bool   // wide canvas (large phones / iPad compat window)

    init(_ width: CGFloat) {
        self.width = width
        self.roomy = width > 430
    }

    var gutter: CGFloat { roomy ? 28 : 20 }
    var cardGap: CGFloat { roomy ? 20 : 14 }
    var titleSize: CGFloat { roomy ? 34 : 28 }
    var hallColumns: Int { width > 700 ? 2 : 1 }

    // Clamp content so it never sprawls on an iPad-sized window.
    var contentCap: CGFloat { min(width, 620) }

    func scaled(_ base: CGFloat) -> CGFloat {
        let factor = min(max(width / 390, 0.86), 1.3)
        return base * factor
    }
}

private struct ExpanseKey: EnvironmentKey {
    static let defaultValue = Expanse(390)
}

extension EnvironmentValues {
    var expanse: Expanse {
        get { self[ExpanseKey.self] }
        set { self[ExpanseKey.self] = newValue }
    }
}

// Wrap a screen body to inject the measured expanse once at the top.
struct Measured<Content: View>: View {
    let build: (Expanse) -> Content

    var body: some View {
        GeometryReader { geo in
            let exp = Expanse(geo.size.width)
            build(exp)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environment(\.expanse, exp)
        }
    }
}
