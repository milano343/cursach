import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {

    @Published var weather: WeatherResponse?
    @Published var forecast: [ForecastItem] = []
    @Published var errorMessage: String?

    private let service = WeatherService()

    func loadWeather(city: String) async {
        do {
            let current = try await service.fetchWeather(city: city)
            let forecastData = try await service.fetchForecast(city: city)

            self.weather = current
            self.forecast = forecastData.list
        } catch {
            self.errorMessage = "Не вдалося знайти місто"
        }
    }
}
