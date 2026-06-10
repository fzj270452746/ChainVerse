import Foundation

// PRD §11 subsystem: reads the forge and names the standout chains.
enum GrowthGraph {

    struct Reading {
        let steadiest: ChainCore?   // 最稳定
        let frailest: ChainCore?    // 最易断裂
        let fastest: ChainCore?     // 成长最快
    }

    static func read(_ chains: [ChainCore]) -> Reading {
        let lived = chains.filter { !$0.nodes.isEmpty }
        let steadiest = lived.max { stability($0) < stability($1) }
        let breakable = lived.filter { Chronology.breaks($0.nodes) > 0 }
        let frailest = breakable.max { fragility($0) < fragility($1) }
        let fastest = lived.max { momentum($0) < momentum($1) }
        return Reading(steadiest: steadiest, frailest: frailest, fastest: fastest)
    }

    // Long unbroken life relative to total → steady.
    static func stability(_ chain: ChainCore) -> Double {
        let total = chain.totalDays
        guard total > 0 else { return 0 }
        return Double(chain.longest) / Double(total) + Double(chain.streak) * 0.01
    }

    // Many breaks over a short life → fragile.
    static func fragility(_ chain: ChainCore) -> Double {
        let total = max(1, chain.totalDays)
        return Double(Chronology.breaks(chain.nodes)) / Double(total) * 100
    }

    // Density of forging in the last two weeks → momentum.
    static func momentum(_ chain: ChainCore) -> Double {
        let cutoff = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let recent = chain.nodes.filter { $0.day >= cutoff }.count
        return Double(recent) / 14.0
    }
}
