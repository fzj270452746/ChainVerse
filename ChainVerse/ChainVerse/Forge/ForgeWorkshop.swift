import SwiftUI

// PRD §6: cast a new chain — title, minimum unit, record method.
// Color and badge are auto-generated, previewed live as the title is typed.
struct ForgeWorkshop: View {
    @ObservedObject var domain: ForgeDomain
    @Environment(\.presentationMode) private var presentation

    @State private var title = ""
    @State private var unit = ""
    @State private var minimum = ""
    @State private var kind: ForgeKind = .mark

    private var draft: ChainCore {
        ChainCore(title: title.isEmpty ? "New Chain" : title,
                  unit: unit, minimum: minimumValue, kind: kind, bornOn: Date())
    }

    private var minimumValue: Double {
        kind == .mark ? 1 : (Double(minimum) ?? 1)
    }

    private var canCast: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        Measured { exp in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    SceneHeader(realm: .forge)

                    preview

                    field("Name", systemImage: "textformat") {
                        TextField("Reading, Running, Writing…", text: $title)
                            .foregroundColor(Palette.ink)
                    }

                    methodPicker

                    if kind != .mark {
                        field("Minimum unit", systemImage: kind.glyph) {
                            HStack {
                                TextField(kind == .span ? "10" : "1", text: $minimum)
                                    .keyboardType(.numberPad)
                                    .frame(width: 70)
                                    .foregroundColor(Palette.ink)
                                TextField(kind == .span ? "minutes" : "pages, km…", text: $unit)
                                    .foregroundColor(Palette.ink)
                            }
                        }
                    }

                    castButton
                    Spacer(minLength: 30)
                }
                .frame(maxWidth: exp.contentCap)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, exp.gutter)
                .padding(.top, 54)
            }
        }
    }

    private var preview: some View {
        HStack(spacing: 16) {
            ChainSeal(chain: draft, size: 64)
            VStack(alignment: .leading, spacing: 4) {
                Text(draft.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Palette.ink)
                Text("Iron · Lv1 · auto-styled")
                    .font(.system(size: 12))
                    .foregroundColor(draft.accent)
                ChainStrip(chain: draft, linkCount: 6, linkSize: 16).frame(height: 24)
            }
            Spacer()
        }
        .forged()
    }

    private var methodPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How you forge it")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Palette.faint)
            ForEach(ForgeKind.allCases) { k in
                Button { withAnimation(.easeOut(duration: 0.2)) { kind = k } } label: {
                    HStack(spacing: 12) {
                        Image(systemName: k.glyph)
                            .foregroundColor(kind == k ? Palette.voidDeep : Palette.faint)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(kind == k ? Palette.ember : Palette.panel))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(k.label).font(.system(size: 15, weight: .semibold)).foregroundColor(Palette.ink)
                            Text(k.blurb).font(.system(size: 11)).foregroundColor(Palette.faint)
                        }
                        Spacer()
                        if kind == k { Image(systemName: "checkmark").foregroundColor(Palette.ember) }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 16).fill(kind == k ? Palette.panelEdge.opacity(0.5) : Palette.panel))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func field<Inner: View>(_ label: String, systemImage: String, @ViewBuilder content: () -> Inner) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Palette.faint)
            content()
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Palette.panel))
        }
    }

    private var castButton: some View {
        Button {
            domain.send(.forge(.cast(draft)))
            presentation.wrappedValue.dismiss()
        } label: {
            HStack { Image(systemName: "hammer.fill"); Text("Forge this Chain") }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Palette.voidDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Capsule().fill(canCast ? Palette.ember : Palette.faint.opacity(0.4)))
        }
        .disabled(!canCast)
    }
}
