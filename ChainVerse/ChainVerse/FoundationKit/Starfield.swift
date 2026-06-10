import SwiftUI

// Tiny deterministic PRNG so stars and layouts stay put across redraws.
struct Drift: RandomNumberGenerator {
    private var state: UInt64
    init(_ seed: Int) { state = UInt64(bitPattern: Int64(seed)) &+ 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

// The void behind every scene: deep gradient plus a fixed scatter of stars.
struct Starfield: View {
    var density = 70

    var body: some View {
        GeometryReader { geo in
            let stars = Self.scatter(count: density, in: geo.size)
            ZStack {
                RadialGradient(
                    colors: [Palette.voidBase, Palette.voidDeep],
                    center: .top, startRadius: 40, endRadius: geo.size.height
                )
                ForEach(stars.indices, id: \.self) { i in
                    let s = stars[i]
                    Circle()
                        .fill(Color.white.opacity(s.glow))
                        .frame(width: s.size, height: s.size)
                        .position(x: s.x, y: s.y)
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    private struct Star { let x, y, size, glow: CGFloat }

    private static func scatter(count: Int, in size: CGSize) -> [Star] {
        var rng = Drift(7321)
        return (0..<count).map { _ in
            Star(
                x: .random(in: 0...size.width, using: &rng),
                y: .random(in: 0...size.height, using: &rng),
                size: .random(in: 0.8...2.6, using: &rng),
                glow: .random(in: 0.06...0.5, using: &rng)
            )
        }
    }
}
