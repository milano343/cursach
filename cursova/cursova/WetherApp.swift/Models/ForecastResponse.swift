import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastItem]
}

struct ForecastItem: Codable {
    let dt: Double
    let main: MainWeather
    let weather: [WeatherCondition]
}
