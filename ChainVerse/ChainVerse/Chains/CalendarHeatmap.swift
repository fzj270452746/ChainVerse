import SwiftUI

// PRD §9: a chain's history as a month grid you can tap to backfill or undo a day.
// Filled cells glow with the chain's accent; future days are inert.
struct CalendarHeatmap: View {
    let chain: ChainCore
    var onToggle: (Date) -> Void

    @State private var month: Date = Chronology.floor(Date())

    private let cal = Calendar.current
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            head
            weekdayRow
            LazyVGrid(columns: cols, spacing: 6) {
                ForEach(slots, id: \.self) { slot in
                    cell(slot)
                }
            }
            Text("Tap a past day to forge or undo it.")
                .font(.system(size: 11))
                .foregroundColor(Palette.faint)
        }
        .forged()
    }

    private var head: some View {
        HStack {
            Text(monthLabel)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Palette.ink)
            Spacer()
            step("chevron.left") { shift(-1) }
            step("chevron.right", disabled: isCurrentMonth) { shift(1) }
        }
    }

    private func step(_ icon: String, disabled: Bool = false, _ act: @escaping () -> Void) -> some View {
        Button(action: act) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(disabled ? Palette.faint.opacity(0.4) : Palette.ink)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Palette.panelEdge.opacity(0.5)))
        }
        .disabled(disabled)
    }

    private var weekdayRow: some View {
        HStack(spacing: 6) {
            ForEach(cal.veryShortWeekdaySymbols, id: \.self) { d in
                Text(d).font(.system(size: 10, weight: .medium))
                    .foregroundColor(Palette.faint)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private func cell(_ slot: Date?) -> some View {
        if let day = slot {
            let forged = Chronology.wasForged(chain.nodes, on: day)
            let future = day > Chronology.floor(Date())
            Button { if !future { onToggle(day) } } label: {
                Text("\(cal.component(.day, from: day))")
                    .font(.system(size: 12, weight: forged ? .bold : .regular))
                    .foregroundColor(color(forged: forged, future: future))
                    .frame(maxWidth: .infinity, minHeight: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(forged ? chain.accent : Palette.panelEdge.opacity(future ? 0.15 : 0.35))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isToday(day) ? chain.accent : .clear, lineWidth: 1.5)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(future)
        } else {
            Color.clear.frame(minHeight: 34)
        }
    }

    private func color(forged: Bool, future: Bool) -> Color {
        if forged { return Palette.voidDeep }
        return future ? Palette.faint.opacity(0.4) : Palette.ink
    }

    // MARK: - month math

    private var slots: [Date?] {
        guard let range = cal.range(of: .day, in: .month, for: month),
              let first = cal.date(from: cal.dateComponents([.year, .month], from: month))
        else { return [] }
        let lead = (cal.component(.weekday, from: first) - cal.firstWeekday + 7) % 7
        var out: [Date?] = Array(repeating: nil, count: lead)
        for d in range {
            out.append(cal.date(byAdding: .day, value: d - 1, to: first))
        }
        return out
    }

    private func isToday(_ d: Date) -> Bool { Chronology.floor(d) == Chronology.floor(Date()) }

    private var isCurrentMonth: Bool {
        cal.isDate(month, equalTo: Date(), toGranularity: .month)
    }

    private func shift(_ by: Int) {
        if let m = cal.date(byAdding: .month, value: by, to: month) { month = m }
    }

    private var monthLabel: String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"
        return f.string(from: month)
    }
}
