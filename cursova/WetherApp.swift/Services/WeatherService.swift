import Foundation

class WeatherService {
    private let apiKey = "ab0069499127cfcfd1acbb1b07b084ed"  
    private let baseURL = "https://api.openweathermap.org/data/2.5"

    func fetchWeather(city: String) async throws -> WeatherResponse {
        let urlString = "\(baseURL)/weather?q=\(city)&appid=\(apiKey)&units=metric"
        let url = URL(string: urlString)!

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }

    func fetchForecast(city: String) async throws -> ForecastResponse {
        let urlString = "\(baseURL)/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        let url = URL(string: urlString)!

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ForecastResponse.self, from: data)
    }
}

