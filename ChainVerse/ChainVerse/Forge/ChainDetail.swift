import SwiftUI

// A single chain up close: its tier, history strip, and the forge action.
// PRD §10: also where you see this chain's own relics.
struct ChainDetail: View {
    @ObservedObject var domain: ForgeDomain
    let chainID: UUID
    @Environment(\.presentationMode) private var presentation

    @State private var logging = false
    @State private var entry = ""
    @State private var editing = false
    @State private var backfillDay: Date?    // day awaiting an amount when backfilling tally/span

    private var chain: ChainCore? { domain.chain(chainID) }

    var body: some View {
        Measured { exp in
            ScrollView(showsIndicators: false) {
                if let chain = chain {
                    VStack(alignment: .leading, spacing: 22) {
                        header(chain)
                        crest(chain)
                        stats(chain)
                        CalendarHeatmap(chain: chain) { tap(chain, on: $0) }
                        relicList(chain)
                        actions(chain)
                        Spacer(minLength: 30)
                    }
                    .frame(maxWidth: exp.contentCap)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, exp.gutter)
                    .padding(.top, 54)
                } else {
                    Text("This chain is gone.").foregroundColor(Palette.faint).padding(.top, 120)
                }
            }
        }
        .overlay(forgeSheet)
        .sheet(isPresented: $editing) {
            if let chain = chain { ChainEditor(domain: domain, chain: chain) }
        }
    }

    // Tap a calendar day: mark chains toggle instantly; counted chains ask for an amount.
    private func tap(_ chain: ChainCore, on day: Date) {
        if Chronology.wasForged(chain.nodes, on: day) {
            domain.send(.forge(.unforge(chain: chain.id, on: day)))
        } else if chain.kind == .mark {
            domain.send(.forge(.forge(chain: chain.id, amount: 1, on: day)))
        } else {
            entry = ""; backfillDay = day; logging = true
        }
    }

    private func header(_ chain: ChainCore) -> some View {
        HStack(spacing: 14) {
            Button { presentation.wrappedValue.dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Palette.ink)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Palette.panel))
            }
            Text(chain.title)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(Palette.ink)
            Spacer()
            Button { editing = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Palette.ink)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Palette.panel))
            }
        }
    }

    private func crest(_ chain: ChainCore) -> some View {
        VStack(spacing: 16) {
            ChainSeal(chain: chain, size: 96)
            Text("\(chain.tier.level) · \(chain.tier.name)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(chain.accent)
            ChainStrip(chain: chain, linkCount: 10, linkSize: 24).frame(height: 36)
            if let next = chain.tier.next {
                Text("\(next.daysToEnter - chain.streak) days to \(next.name)")
                    .font(.system(size: 12)).foregroundColor(Palette.faint)
            } else {
                Text("Highest tier reached").font(.system(size: 12)).foregroundColor(Palette.faint)
            }
        }
        .frame(maxWidth: .infinity)
        .forged(24)
    }

    private func stats(_ chain: ChainCore) -> some View {
        HStack(spacing: 12) {
            stat("\(chain.streak)", chain.broken ? "broken" : "current")
            stat("\(chain.longest)", "longest")
            stat("\(chain.totalDays)", "days kept")
            stat("\(Chronology.breaks(chain.nodes))", "breaks")
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundColor(Palette.ink)
            Text(label).font(.system(size: 11)).foregroundColor(Palette.faint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Palette.panel))
    }

    @ViewBuilder
    private func relicList(_ chain: ChainCore) -> some View {
        let relics = Chronology.relics(chain.nodes)
        if !relics.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Relics of this chain")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(Palette.faint)
                ForEach(relics.reversed()) { run in
                    HStack {
                        Image(systemName: "link.badge.plus").foregroundColor(Palette.faint)
                        Text("\(run.length) days").foregroundColor(Palette.ink).font(.system(size: 14, weight: .medium))
                        Spacer()
                        Text(span(run)).foregroundColor(Palette.faint).font(.system(size: 12))
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Palette.panel))
                }
            }
        }
    }

    private func actions(_ chain: ChainCore) -> some View {
        VStack(spacing: 12) {
            Button {
                if chain.kind == .mark {
                    domain.send(.forge(.forge(chain: chain.id, amount: 1, on: Date())))
                } else {
                    entry = ""; backfillDay = Date(); logging = true
                }
            } label: {
                Label(chain.forgedToday ? "Forged today" : "Forge today", systemImage: chain.forgedToday ? "checkmark.circle.fill" : "hammer.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(chain.forgedToday ? Palette.faint : Palette.voidDeep)
                    .frame(maxWidth: .infinity).padding(.vertical, 15)
                    .background(Capsule().fill(chain.forgedToday ? Palette.panel : chain.accent))
            }
            .disabled(chain.forgedToday)

            if chain.forgedToday {
                Button { domain.send(.forge(.unforge(chain: chain.id, on: Date()))) } label: {
                    Text("Undo today").font(.system(size: 13)).foregroundColor(Palette.faint)
                }
            }

            Button { domain.send(.relic(.dissolve(chain: chain.id))); presentation.wrappedValue.dismiss() } label: {
                Text("Dissolve to archive").font(.system(size: 13)).foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.4))
            }
        }
    }

    // Numeric / duration entry, kept inline rather than a modal sheet. Works for
    // both today and any backfilled day picked on the calendar.
    @ViewBuilder
    private var forgeSheet: some View {
        if logging, let chain = chain {
            let day = backfillDay ?? Date()
            ZStack {
                Color.black.opacity(0.55).ignoresSafeArea().onTapGesture { logging = false }
                VStack(spacing: 16) {
                    Text(prompt(day)).font(.system(size: 17, weight: .semibold)).foregroundColor(Palette.ink)
                    TextField(chain.kind == .span ? "minutes" : "amount", text: $entry)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(chain.accent)
                        .padding().background(RoundedRectangle(cornerRadius: 14).fill(Palette.panel))
                    Button {
                        let amount = Double(entry) ?? chain.minimum
                        domain.send(.forge(.forge(chain: chain.id, amount: amount, on: day)))
                        logging = false
                    } label: {
                        Text("Forge").font(.system(size: 15, weight: .bold)).foregroundColor(Palette.voidDeep)
                            .frame(maxWidth: .infinity).padding(.vertical, 13)
                            .background(Capsule().fill(chain.accent))
                    }
                }
                .padding(22)
                .background(RoundedRectangle(cornerRadius: 24).fill(Palette.voidBase))
                .padding(.horizontal, 40)
            }
            .transition(.opacity)
        }
    }

    private func prompt(_ day: Date) -> String {
        if Chronology.floor(day) == Chronology.floor(Date()) { return "How much today?" }
        let f = DateFormatter(); f.dateFormat = "MMM d"
        return "How much on \(f.string(from: day))?"
    }

    private func span(_ run: ChainRun) -> String {
        let f = DateFormatter(); f.dateFormat = "MMM d"
        return "\(f.string(from: run.start)) – \(f.string(from: run.end))"
    }
}
