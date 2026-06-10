import SwiftUI

// PRD §14: spatial navigation, not a tab bar. Portals sit in the hall as a
// constellation of doorways into the other realms.
struct PortalDock: View {
    var onOpen: (Realm) -> Void

    private let realms = Realm.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Realms")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Palette.faint)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(realms) { realm in
                    Button { onOpen(realm) } label: { Portal(realm: realm) }
                        .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

private struct Portal: View {
    let realm: Realm
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: realm.glyph)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(realm.hue)
                .frame(width: 40, height: 40)
                .background(Circle().fill(realm.hue.opacity(0.14)))
            VStack(alignment: .leading, spacing: 2) {
                Text(realm.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Palette.ink)
                Text(realm.caption)
                    .font(.system(size: 11))
                    .foregroundColor(Palette.faint)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.panel)
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.panelEdge, lineWidth: 1))
        )
    }
}

// Reused header for pushed realms: back chevron, title, subtitle, themed glyph.
struct SceneHeader: View {
    let realm: Realm
    @Environment(\.presentationMode) private var presentation

    var body: some View {
        HStack(spacing: 14) {
            Button { presentation.wrappedValue.dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Palette.ink)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Palette.panel))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(realm.title)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(Palette.ink)
                Text(realm.caption)
                    .font(.system(size: 12))
                    .foregroundColor(Palette.faint)
            }
            Spacer()
            Image(systemName: realm.glyph)
                .font(.system(size: 20))
                .foregroundColor(realm.hue)
        }
    }
}
