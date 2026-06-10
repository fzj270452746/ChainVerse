import Foundation

// PRD §16 subsystem: watches chains and emits notices the UI can react to —
// a chain just broke, a chain just climbed a tier. Read-side, no mutation.
enum ChainObserver {

    enum Notice: Identifiable {
        case broke(ChainCore, lost: Int)     // streak snapped, days lost
        case climbed(ChainCore, to: ChainTier)
        var id: String {
            switch self {
            case .broke(let c, _): return "broke-\(c.id)"
            case .climbed(let c, let t): return "climb-\(c.id)-\(t.rawValue)"
            }
        }
    }

    // Compare a chain before/after an event to surface a notice.
    static func diff(before: ChainCore?, after: ChainCore) -> Notice? {
        guard let before = before else { return nil }
        if before.tier < after.tier { return .climbed(after, to: after.tier) }
        if before.streak > 1 && after.streak == 0 {
            return .broke(after, lost: before.streak)
        }
        return nil
    }

    // On launch, flag chains that silently broke while the app was away.
    static func lapsed(_ chains: [ChainCore]) -> [Notice] {
        chains.compactMap { chain in
            guard chain.broken, let last = Chronology.relics(chain.nodes).last else { return nil }
            return .broke(chain, lost: last.length)
        }
    }
}
