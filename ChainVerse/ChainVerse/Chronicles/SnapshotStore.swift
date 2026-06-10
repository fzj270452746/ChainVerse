import Foundation

// The serialized shape of the whole forge. PRD §15: ForgeSnapshot.
struct ForgeSnapshot: Codable {
    var chains: [ChainCore] = []
    var dissolved: [UUID] = []   // chains retired to the archive
    var version = 1
}

// Plain disk persistence for the snapshot. PRD §18: …→ ChronicleVault → SnapshotStore.
struct SnapshotStore {
    private let url: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        url = docs.appendingPathComponent("forge.snapshot.json")
    }

    func load() -> ForgeSnapshot {
        guard let data = try? Data(contentsOf: url),
              let snap = try? JSONDecoder().decode(ForgeSnapshot.self, from: data)
        else { return ForgeSnapshot() }
        return snap
    }

    func save(_ snap: ForgeSnapshot) {
        guard let data = try? JSONEncoder().encode(snap) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
