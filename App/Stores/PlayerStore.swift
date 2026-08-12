import AVFoundation

@MainActor
final class PlayerStore: ObservableObject {
    @Published private(set) var currentStation: Station?
    @Published private(set) var isPlaying = false

    private let player = AVPlayer()

    init() {
        // 백그라운드 재생 시도 — 무료 계정에서는 제한적, 안되면 포그라운드 유지 UX로 전환
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(station: Station) {
        let item = AVPlayerItem(url: station.streamUrl)
        player.replaceCurrentItem(with: item)
        player.play()
        currentStation = station
        isPlaying = true
    }

    // ponytail: 딥링크 시점엔 아직 전체 채널 목록이 없어 샘플에서 조회. StationListView 붙으면 실제 목록으로 교체.
    func play(id: String) {
        guard let station = Station.samples.first(where: { $0.id == id }) else { return }
        play(station: station)
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func resume() {
        player.play()
        isPlaying = true
    }
}
