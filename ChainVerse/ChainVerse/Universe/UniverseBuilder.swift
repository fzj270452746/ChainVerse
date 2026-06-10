import Foundation
import CoreGraphics

// PRD §9 + §16: weaves chains into a relationship network for the universe map.
// Bonds emerge from behavior — chains forged on the same days are bound.
enum UniverseBuilder {

    struct Bond: Identifiable {
        let a: UUID
        let b: UUID
        let weight: Double  // 0…1 strength of shared days
        var id: String { "\(a.uuidString)-\(b.uuidString)" }
    }

    struct Placement: Identifiable {
        let chain: ChainCore
        let point: CGPoint  // unit space 0…1
        var id: UUID { chain.id }
    }

    // Co-forge overlap normalized by the smaller chain's footprint.
    static func bonds(_ chains: [ChainCore]) -> [Bond] {
        let dayset = chains.map { ($0.id, Set($0.nodes.map { Chronology.floor($0.day) })) }
        var out: [Bond] = []
        for i in 0..<dayset.count {
            for j in (i + 1)..<dayset.count {
                let shared = dayset[i].1.intersection(dayset[j].1).count
                guard shared > 0 else { continue }
                let base = max(1, min(dayset[i].1.count, dayset[j].1.count))
                out.append(Bond(a: dayset[i].0, b: dayset[j].0, weight: min(1, Double(shared) / Double(base))))
            }
        }
        return out
    }

    // Arrange chains on a ring, stronger chains pulled toward the core.
    static func constellation(_ chains: [ChainCore]) -> [Placement] {
        guard !chains.isEmpty else { return [] }
        let n = Double(chains.count)
        return chains.enumerated().map { idx, chain in
            let angle: Double = (Double(idx) / n) * 2 * .pi - (.pi / 2)
            let strength: Double = min(1, Double(chain.streak) / 120)
            let radius: Double = 0.42 - strength * 0.22   // strong chains sit nearer center
            let x: Double = 0.5 + cos(angle) * radius
            let y: Double = 0.5 + sin(angle) * radius
            return Placement(chain: chain, point: CGPoint(x: x, y: y))
        }
    }
}
