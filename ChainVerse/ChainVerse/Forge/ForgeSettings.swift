import SwiftUI

// The forge's settings: notification permission, a glance at reminders in play,
// and a guarded "erase everything". Reached from the hall, not a tab.
struct ForgeSettings: View {
    @ObservedObject var domain: ForgeDomain
    @Environment(\.presentationMode) private var presentation

    @State private var allowed = false
    @State private var confirmWipe = false

    private var reminding: [ChainCore] {
        domain.activeChains.filter { $0.reminder != nil }
    }

    var body: some View {
        Measured { exp in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    notifications
                    if !reminding.isEmpty { remindersList }
                    about
                    wipe
                    Spacer(minLength: 30)
                }
                .frame(maxWidth: exp.contentCap)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, exp.gutter)
                .padding(.top, 54)
            }
        }
        .onAppear { Reminders.status { allowed = $0 } }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button { presentation.wrappedValue.dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Palette.ink)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Palette.panel))
            }
            Text("Settings")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(Palette.ink)
            Spacer()
            Image(systemName: "gearshape.fill")
                .font(.system(size: 20))
                .foregroundColor(Palette.faint)
        }
    }

    private var notifications: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Notifications")
            HStack(spacing: 12) {
                Image(systemName: allowed ? "bell.fill" : "bell.slash.fill")
                    .foregroundColor(allowed ? Palette.ember : Palette.faint)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Palette.panelEdge.opacity(0.5)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(allowed ? "Reminders allowed" : "Reminders off")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(Palette.ink)
                    Text(allowed ? "Set a time on any chain to be nudged."
                                 : "Enable to get daily nudges per chain.")
                        .font(.system(size: 11)).foregroundColor(Palette.faint)
                }
                Spacer()
                if !allowed {
                    Button { Reminders.request { allowed = $0 } } label: {
                        Text("Allow").font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Palette.voidDeep)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Capsule().fill(Palette.ember))
                    }
                }
            }
            .forged(14)
        }
    }

    private var remindersList: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Active reminders")
            ForEach(reminding) { c in
                HStack {
                    Image(systemName: c.badge).foregroundColor(c.accent)
                    Text(c.title).font(.system(size: 14, weight: .medium)).foregroundColor(Palette.ink)
                    Spacer()
                    Text(time(c.reminder)).font(.system(size: 13)).foregroundColor(Palette.faint)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Palette.panel))
            }
        }
    }

    private var about: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("About")
            VStack(alignment: .leading, spacing: 6) {
                row("Chains", "\(domain.activeChains.count) standing")
                row("Archived", "\(domain.dissolvedChains.count)")
                row("Version", "1.0")
            }
            .forged(14)
        }
    }

    private var wipe: some View {
        VStack(spacing: 10) {
            if confirmWipe {
                Text("Erase every chain, relic, and record? This can't be undone.")
                    .font(.system(size: 12)).foregroundColor(Palette.faint)
                    .multilineTextAlignment(.center)
                HStack(spacing: 12) {
                    Button { confirmWipe = false } label: {
                        Text("Keep").font(.system(size: 14, weight: .semibold)).foregroundColor(Palette.ink)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Capsule().fill(Palette.panel))
                    }
                    Button {
                        domain.eraseEverything()
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Erase all").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Capsule().fill(Color(red: 0.9, green: 0.3, blue: 0.3)))
                    }
                }
            } else {
                Button { confirmWipe = true } label: {
                    Label("Erase all data", systemImage: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.4))
                }
            }
        }
        .padding(.top, 8)
    }

    private func sectionTitle(_ t: String) -> some View {
        Text(t).font(.system(size: 13, weight: .semibold)).foregroundColor(Palette.faint)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundColor(Palette.ink)
            Spacer()
            Text(value).font(.system(size: 14, weight: .medium)).foregroundColor(Palette.faint)
        }
    }

    private func time(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let f = DateFormatter(); f.timeStyle = .short
        return f.string(from: date)
    }
}
