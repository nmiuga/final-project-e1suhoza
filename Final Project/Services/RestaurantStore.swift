import Combine
import Foundation

@MainActor
final class RestaurantStore: ObservableObject {
    @Published private(set) var restaurants: [Restaurant] = []

    private let fileName = "restaurants.json"

    init() {
        load()
    }

    func add(_ restaurant: Restaurant) {
        restaurants.insert(restaurant, at: 0)
        save()
    }

    func update(_ restaurant: Restaurant) {
        guard let index = restaurants.firstIndex(where: { $0.id == restaurant.id }) else {
            return
        }
        restaurants[index] = restaurant
        save()
    }

    func delete(_ restaurant: Restaurant) {
        for fileName in restaurant.photoFileNames {
            ImageStore.shared.deleteImage(fileName: fileName)
        }
        restaurants.removeAll { $0.id == restaurant.id }
        save()
    }

    func sorted(by option: SortOption) -> [Restaurant] {
        switch option {
        case .recent:
            return restaurants.sorted { $0.visitDate > $1.visitDate }
        case .rating:
            return restaurants.sorted { $0.rating > $1.rating }
        case .name:
            return restaurants.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(restaurants)
            let url = try fileURL()
            try data.write(to: url, options: .atomic)
        } catch {
            // Intentionally ignore persistence errors for now.
        }
    }

    private func load() {
        do {
            let url = try fileURL()
            let data = try Data(contentsOf: url)
            restaurants = try JSONDecoder().decode([Restaurant].self, from: data)
        } catch {
            restaurants = []
        }
    }

    private func fileURL() throws -> URL {
        let documents = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return documents.appendingPathComponent(fileName)
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case recent = "Recent"
    case rating = "Rating"
    case name = "Name"

    var id: String { rawValue }
}
