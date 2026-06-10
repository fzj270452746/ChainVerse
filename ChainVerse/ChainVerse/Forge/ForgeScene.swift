import SwiftUI

// The root of the app. PRD §5/§14: the Chain Hall is home; realms are reached
// through spatial portals, not a tab bar. Everything hangs off one domain.
struct ForgeScene: View {
    @StateObject private var domain = ForgeDomain()
    @State private var route: Realm?
    @State private var castingNew = false
    @State private var openSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                Starfield()
                ChainHall(
                    domain: domain,
                    onOpen: { route = $0 },
                    onCast: { castingNew = true },
                    onSettings: { openSettings = true }
                )

                // Hidden links drive navigation so the hall stays a custom layout.
                ForEach(Realm.allCases) { realm in
                    NavigationLink(
                        destination: destination(realm),
                        tag: realm,
                        selection: $route
                    ) { EmptyView() }
                    .opacity(0)
                }
                NavigationLink(
                    destination: ForgeWorkshop(domain: domain).withVoid(),
                    isActive: $castingNew
                ) { EmptyView() }
                .opacity(0)
                NavigationLink(
                    destination: ForgeSettings(domain: domain).withVoid(),
                    isActive: $openSettings
                ) { EmptyView() }
                .opacity(0)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // one column on iPad compat too
        .accentColor(Palette.ember)
        .overlay(NoticeBanner(notice: domain.notice) { domain.notice = nil })
    }

    @ViewBuilder
    private func destination(_ realm: Realm) -> some View {
        Group {
            switch realm {
            case .forge: ForgeWorkshop(domain: domain)
            case .universe: UniverseMap(domain: domain)
            case .relics: RelicHall(domain: domain)
            case .growth: GrowthArchive(domain: domain)
            case .museum: ChainMuseum(domain: domain)
            case .chronicle: ChronicleScene(domain: domain)
            }
        }
        .withVoid()
    }
}

// Drops the starfield behind any pushed realm and hides the default bar chrome.
extension View {
    func withVoid() -> some View {
        ZStack { Starfield(); self }
            .navigationBarHidden(true)
    }
}
