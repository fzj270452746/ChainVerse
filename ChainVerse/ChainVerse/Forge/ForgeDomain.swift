import SwiftUI
import Combine

// PRD §16: the one root that owns the forge. Scenes send events in; it folds them
// into the snapshot, persists, and republishes. The only ObservableObject in the app,
// kept at the boundary so the rest stays event-driven rather than @Published-driven.
final class ForgeDomain: ObservableObject {

    private(set) var snapshot: ForgeSnapshot
    private let store = SnapshotStore()

    // Latest notice (a break or a tier climb) for the UI to celebrate or mourn.
    @Published var notice: ChainObserver.Notice?

    init() {
        snapshot = store.load()
    }

    // Single entry point for every mutation in the app.
    func send(_ event: DomainEvent) {
        let prior = focusedChain(of: event)

        switch event {
        case .forge(let e): ChainForge.apply(e, to: &snapshot)
        case .relic(let e): RelicArchive.apply(e, to: &snapshot)
        }

        syncReminders(for: event)

        if let prior, let after = chain(prior.id) {
            notice = ChainObserver.diff(before: prior, after: after)
        }
        store.save(snapshot)
        objectWillChange.send()
    }

    // Wipe the whole forge — used by the settings "erase everything" action.
    func eraseEverything() {
        snapshot = ForgeSnapshot()
        Reminders.clearAll()
        store.save(snapshot)
        objectWillChange.send()
    }

    // Reflect reminder/erase events into the notification center as a side effect,
    // kept out of the pure forge logic.
    private func syncReminders(for event: DomainEvent) {
        switch event {
        case .forge(.remind(let id, _)),
             .forge(.rename(let id, _)),
             .forge(.edit(let id, _, _, _)),
             .relic(.revive(let id)):
            if let c = chain(id) { Reminders.sync(c) }
        case .forge(.erase(let id)), .relic(.dissolve(let id)):
            Reminders.cancel(id)
        default:
            break
        }
    }

    // MARK: - read side (scenes pull derived views, never raw storage)

    var activeChains: [ChainCore] {
        snapshot.chains.filter { !snapshot.dissolved.contains($0.id) }
    }

    var allChains: [ChainCore] { snapshot.chains }

    var dissolvedChains: [ChainCore] {
        snapshot.chains.filter { snapshot.dissolved.contains($0.id) }
    }

    func chain(_ id: UUID) -> ChainCore? {
        snapshot.chains.first { $0.id == id }
    }

    func isDissolved(_ id: UUID) -> Bool { snapshot.dissolved.contains(id) }

    private func focusedChain(of event: DomainEvent) -> ChainCore? {
        switch event {
        case .forge(.forge(let id, _, _)), .forge(.unforge(let id, _)), .forge(.rename(let id, _)):
            return chain(id)
        default: return nil
        }
    }
}
