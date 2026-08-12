import SwiftUI

struct StationListView: View {
    @EnvironmentObject private var playerStore: PlayerStore
    @EnvironmentObject private var favoritesStore: FavoritesStore

    @State private var stations: [Station] = Station.samples
    @State private var searchText = ""
    @State private var selectedCountry: String?

    private let service = RadioBrowserService()

    private var countries: [String] {
        Array(Set(stations.map(\.country))).sorted()
    }

    private var filteredStations: [Station] {
        stations.filter { selectedCountry == nil || $0.country == selectedCountry }
    }

    var body: some View {
        VStack(spacing: 0) {
            countryFilterBar
            List(filteredStations) { station in
                StationRow(station: station, isFavorite: favoritesStore.isFavorite(station.id))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        playerStore.play(station: station)
                        favoritesStore.markPlayed(station.id)
                    }
                    .swipeActions {
                        Button(favoritesStore.isFavorite(station.id) ? "해제" : "즐겨찾기") {
                            if favoritesStore.isFavorite(station.id) {
                                favoritesStore.remove(stationId: station.id)
                            } else {
                                favoritesStore.add(stationId: station.id)
                            }
                        }
                        .tint(.yellow)
                    }
            }
            .listStyle(.plain)
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, newValue in
            Task { await search(newValue) }
        }
        .task { await loadTop() }
    }

    private var countryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "전체", isSelected: selectedCountry == nil) { selectedCountry = nil }
                ForEach(countries, id: \.self) { country in
                    chip(title: country, isSelected: selectedCountry == country) { selectedCountry = country }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }

    // 국가 필터 칩은 현재 로드된 목록 기준 — 전체 국가 목록 API(/json/countries)는 필요해지면 추가
    private func loadTop() async {
        if let result = try? await service.topStations() {
            stations = result
        }
    }

    private func search(_ query: String) async {
        guard !query.isEmpty else { await loadTop(); return }
        if let result = try? await service.search(name: query) {
            stations = result
        }
    }
}

struct StationRow: View {
    let station: Station
    let isFavorite: Bool

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: station.faviconUrl) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(station.name).font(.subheadline).fontWeight(.medium)
                Text("\(station.country) · \(station.bitrate)kbps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isFavorite {
                Image(systemName: "star.fill").foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}
