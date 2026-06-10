import Foundation

// PRD §19: state moves through events, not scattered @Published flags.
// Every mutation in the app is one of these, dispatched into ForgeDomain.

enum ForgeEvent {
    case cast(ChainCore)                                  // forge a brand-new chain
    case forge(chain: UUID, amount: Double, on: Date)     // log a day (today or backfilled)
    case unforge(chain: UUID, on: Date)                   // undo a logged day
    case rename(chain: UUID, title: String)
    case edit(chain: UUID, title: String, unit: String, minimum: Double)
    case remind(chain: UUID, at: Date?)                   // set/clear the daily reminder
    case erase(chain: UUID)                               // remove a chain for good
}

enum RelicEvent {
    case dissolve(chain: UUID)   // retire a chain to the archive, keep its relics
    case revive(chain: UUID)     // bring a dissolved chain back to the hall
}

// The two event families fold into one channel the domain consumes.
enum DomainEvent {
    case forge(ForgeEvent)
    case relic(RelicEvent)
}
