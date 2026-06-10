import Foundation

// PRD §16 subsystem: applies forge events to chains. Business logic, no UI, no storage.
enum ChainForge {

    static func apply(_ event: ForgeEvent, to snap: inout ForgeSnapshot) {
        switch event {
        case .cast(let chain):
            snap.chains.append(chain)

        case .forge(let id, let amount, let day):
            mutate(id, in: &snap) { chain in
                let d = Chronology.floor(day)
                if let i = chain.nodes.firstIndex(where: { Chronology.floor($0.day) == d }) {
                    chain.nodes[i].amount = amount        // re-forge same day → update
                } else {
                    chain.nodes.append(ChainNode(day: d, amount: amount))
                }
            }

        case .unforge(let id, let day):
            mutate(id, in: &snap) { chain in
                let d = Chronology.floor(day)
                chain.nodes.removeAll { Chronology.floor($0.day) == d }
            }

        case .rename(let id, let title):
            mutate(id, in: &snap) { $0.title = title }

        case .edit(let id, let title, let unit, let minimum):
            mutate(id, in: &snap) { chain in
                chain.title = title
                chain.unit = unit
                chain.minimum = max(0, minimum)
            }

        case .remind(let id, let at):
            mutate(id, in: &snap) { $0.reminder = at }

        case .erase(let id):
            snap.chains.removeAll { $0.id == id }
            snap.dissolved.removeAll { $0 == id }
        }
    }

    private static func mutate(_ id: UUID, in snap: inout ForgeSnapshot, _ change: (inout ChainCore) -> Void) {
        guard let i = snap.chains.firstIndex(where: { $0.id == id }) else { return }
        change(&snap.chains[i])
    }
}

// PRD §16 subsystem: handles retiring and reviving chains.
enum RelicArchive {

    static func apply(_ event: RelicEvent, to snap: inout ForgeSnapshot) {
        switch event {
        case .dissolve(let id):
            if !snap.dissolved.contains(id) { snap.dissolved.append(id) }
        case .revive(let id):
            snap.dissolved.removeAll { $0 == id }
        }
    }

    // Every sealed run across the forge, newest first. PRD §10 遗迹.
    static func relics(in chains: [ChainCore]) -> [RelicEntry] {
        chains.flatMap { chain in
            Chronology.relics(chain.nodes).map { run in
                RelicEntry(chain: chain, run: run)
            }
        }
        .sorted { $0.run.end > $1.run.end }
    }
}

// A broken stretch of a chain, preserved as growth history.
struct RelicEntry: Identifiable {
    let chain: ChainCore
    let run: ChainRun
    var id: UUID { run.id }
}
