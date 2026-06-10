import SwiftUI

// PRD §7: the product home. Active chains as cards, plus portals to other realms.
struct ChainHall: View {
    @ObservedObject var domain: ForgeDomain
    var onOpen: (Realm) -> Void
    var onCast: () -> Void
    var onSettings: () -> Void

    var body: some View {
        Measured { span in
            ScrollView(showsIndicators: false) {
                VStack(spacing: span.cardGap + 6) {
                    masthead(span)
                    if domain.activeChains.isEmpty {
                        EmptyForge(onCast: onCast)
                            .padding(.top, 40)
                    } else {
                        cards(span)
                    }
                    PortalDock(onOpen: onOpen)
                        .padding(.top, 8)
                    Spacer(minLength: 30)
                }
                .frame(maxWidth: span.contentCap)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, span.gutter)
                .padding(.top, 64)
            }
        }
    }

    private func masthead(_ span: Expanse) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Chain Hall")
                    .font(.system(size: span.titleSize, weight: .heavy, design: .rounded))
                    .foregroundColor(Palette.ink)
                Text(roster)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Palette.faint)
            }
            Spacer()
            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Palette.ink)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.panel))
            }
            Button(action: onCast) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Palette.voidDeep)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.ember))
                    .shadow(color: Palette.ember.opacity(0.5), radius: 8)
            }
        }
    }

    private var roster: String {
        let n = domain.activeChains.count
        let kept = domain.activeChains.filter { $0.forgedToday }.count
        if n == 0 { return "No chains yet" }
        return "\(n) chain\(n == 1 ? "" : "s") · \(kept) forged today"
    }

    private func cards(_ span: Expanse) -> some View {
        let cols = span.hallColumns
        let columns = Array(repeating: GridItem(.flexible(), spacing: span.cardGap), count: cols)
        return LazyVGrid(columns: columns, spacing: span.cardGap) {
            ForEach(domain.activeChains) { chain in
                NavigationLink(destination: ChainDetail(domain: domain, chainID: chain.id).withVoid()) {
                    ChainCard(chain: chain) {
                        domain.send(.forge(.forge(chain: chain.id, amount: chain.minimum, on: Date())))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// Shown when the forge is empty — invites the first cast without feeling like a list.
struct EmptyForge: View {
    var onCast: () -> Void
    var body: some View {
        VStack(spacing: 18) {
            ChainLink()
                .stroke(Palette.faint.opacity(0.5), lineWidth: 3)
                .frame(width: 70, height: 98)
            Text("Your universe is empty")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Palette.ink)
            Text("Forge your first chain. Keep it daily and watch it grow from iron to legend.")
                .font(.system(size: 14))
                .foregroundColor(Palette.faint)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button(action: onCast) {
                Text("Cast a Chain")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Palette.voidDeep)
                    .padding(.horizontal, 26).padding(.vertical, 12)
                    .background(Capsule().fill(Palette.ember))
            }
        }
        .forged(26)
    }
}
