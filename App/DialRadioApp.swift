import SwiftUI

// URL Scheme "myradio" — Playgrounds 프로젝트 설정(Package.swift)에서 직접 등록 필요
@main
struct DialRadioApp: App {
    @StateObject private var playerStore = PlayerStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerStore)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    // myradio://play?id={stationUUID}
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "myradio", url.host == "play",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let stationId = components.queryItems?.first(where: { $0.name == "id" })?.value
        else { return }

        playerStore.play(id: stationId)
    }
}

struct ContentView: View {
    @EnvironmentObject private var playerStore: PlayerStore

    var body: some View {
        VStack(spacing: 12) {
            Text(playerStore.currentStation?.name ?? "DialRadio")
            if playerStore.isPlaying {
                Button("일시정지") { playerStore.pause() }
            }
        }
    }
}
