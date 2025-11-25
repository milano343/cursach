import Foundation

struct WeatherResponse: Codable {
    let name: String
    let weather: [WeatherCondition]
    let main: MainWeather
}

struct WeatherCondition: Codable {
    let description: String
    let icon: String
}

struct MainWeather: Codable {
    let temp: Double
    let feels_like: Double
}
