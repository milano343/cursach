import Foundation
import Combine

class FavoritesManager: ObservableObject {
    @Published var favorites: [String] {
        didSet {
            UserDefaults.standard.set(favorites, forKey: "favorites")
        }
    }

    init() {
        self.favorites = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
    }

    func add(city: String) {
        if !favorites.contains(city) {
            favorites.append(city)
        }
    }
}
