import SwiftUI

// Edit an existing chain: rename, change its unit/minimum, set a daily reminder,
// or erase it for good. Reached from the chain detail. Record method is fixed at
// cast time (it changes the meaning of past nodes), so it isn't editable here.
struct ChainEditor: View {
    @ObservedObject var domain: ForgeDomain
    let chain: ChainCore
    @Environment(\.presentationMode) private var presentation

    @State private var title: String
    @State private var unit: String
    @State private var minimum: String
    @State private var remindOn: Bool
    @State private var remindAt: Date
    @State private var confirmErase = false

    init(domain: ForgeDomain, chain: ChainCore) {
        self.domain = domain
        self.chain = chain
        let whole = chain.minimum == chain.minimum.rounded()
        let minText = whole ? String(Int(chain.minimum)) : String(chain.minimum)
        _title = State(initialValue: chain.title)
        _unit = State(initialValue: chain.unit)
        _minimum = State(initialValue: minText)
        _remindOn = State(initialValue: chain.reminder != nil)
        _remindAt = State(initialValue: chain.reminder ?? Self.defaultTime)
    }

    private static var defaultTime: Date {
        Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    }

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        Measured { exp in
            ZStack {
                Palette.voidBase.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        bar
                        field("Name", systemImage: "textformat") {
                            TextField("Name", text: $title).foregroundColor(Palette.ink)
                        }
                        if chain.kind != .mark {
                            field("Minimum unit", systemImage: chain.kind.glyph) {
                                HStack {
                                    TextField("1", text: $minimum)
                                        .keyboardType(.numberPad).frame(width: 70)
                                        .foregroundColor(Palette.ink)
                                    TextField(chain.kind == .span ? "minutes" : "pages, km…", text: $unit)
                                        .foregroundColor(Palette.ink)
                                }
                            }
                        }
                        reminderBlock
                        eraseBlock
                        Spacer(minLength: 30)
                    }
                    .frame(maxWidth: exp.contentCap)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, exp.gutter)
                    .padding(.top, 22)
                }
            }
        }
    }

    private var bar: some View {
        HStack {
            Button { presentation.wrappedValue.dismiss() } label: {
                Text("Cancel").font(.system(size: 15)).foregroundColor(Palette.faint)
            }
            Spacer()
            Text("Edit Chain").font(.system(size: 16, weight: .semibold)).foregroundColor(Palette.ink)
            Spacer()
            Button(action: save) {
                Text("Save").font(.system(size: 15, weight: .semibold))
                    .foregroundColor(canSave ? Palette.ember : Palette.faint)
            }
            .disabled(!canSave)
        }
    }

    private var reminderBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $remindOn) {
                Label("Daily reminder", systemImage: "bell.fill")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(Palette.ink)
            }
            .toggleStyle(SwitchToggleStyle(tint: chain.accent))
            .onChange(of: remindOn) { on in if on { Reminders.request { _ in } } }

            if remindOn {
                DatePicker("", selection: $remindAt, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(maxHeight: 110)
                    .clipped()
            }
        }
        .forged()
    }

    private var eraseBlock: some View {
        VStack(spacing: 10) {
            if confirmErase {
                Text("Erase this chain and all its history? This can't be undone.")
                    .font(.system(size: 12)).foregroundColor(Palette.faint)
                    .multilineTextAlignment(.center)
                HStack(spacing: 12) {
                    Button { confirmErase = false } label: {
                        Text("Keep").font(.system(size: 14, weight: .semibold)).foregroundColor(Palette.ink)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Capsule().fill(Palette.panel))
                    }
                    Button(action: erase) {
                        Text("Erase").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Capsule().fill(Color(red: 0.9, green: 0.3, blue: 0.3)))
                    }
                }
            } else {
                Button { confirmErase = true } label: {
                    Label("Erase chain", systemImage: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.4))
                }
            }
        }
        .padding(.top, 8)
    }

    private func field<Inner: View>(_ label: String, systemImage: String, @ViewBuilder content: () -> Inner) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: systemImage)
                .font(.system(size: 13, weight: .semibold)).foregroundColor(Palette.faint)
            content()
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Palette.panel))
        }
    }

    private func save() {
        let min = Double(minimum) ?? chain.minimum
        domain.send(.forge(.edit(chain: chain.id, title: title, unit: unit, minimum: min)))
        domain.send(.forge(.remind(chain: chain.id, at: remindOn ? remindAt : nil)))
        presentation.wrappedValue.dismiss()
    }

    private func erase() {
        presentation.wrappedValue.dismiss()
        domain.send(.forge(.erase(chain: chain.id)))
    }
}
