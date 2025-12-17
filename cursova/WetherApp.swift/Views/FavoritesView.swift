import SwiftUI

struct FavoritesView: View {

    @ObservedObject var favorites: FavoritesManager
    @StateObject private var vm = WeatherViewModel()
    var onSelect: (String) -> Void
    
    @State private var cityTemperatures: [String: (temp: Int, condition: String)] = [:]

    var body: some View {
        ZStack {
            // ФОН 
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0/255, green: 70/255, blue: 200/255),
                    Color(red: 135/255, green: 206/255, blue: 250/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10) {
                if favorites.favorites.isEmpty {
                    VStack {
                        Spacer()
                        Text("У вас ще немає улюблених міст.")
                            .foregroundColor(.white)
                            .font(.title3)
                            .padding()
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(favorites.favorites, id: \.self) { city in
                                Button {
                                    onSelect(city)
                                } label: {
                                    HStack {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                        
                                        Text(city)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if let data = cityTemperatures[city] {
                                            HStack(spacing: 8) {
                                                Image(systemName: weatherIcon(for: data.condition))
                                                    .font(.title2)
                                                    .foregroundColor(.blue)
                                                
                                                Text("\(data.temp)°C")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.primary)
                                            }
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(14)
                                    .shadow(radius: 3)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Улюблені міста")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAllTemperatures()
        }
    }
    
    func loadAllTemperatures() {
        for city in favorites.favorites {
            Task {
                await vm.loadWeather(city: city)
                if let weather = vm.weather {
                    cityTemperatures[city] = (
                        temp: Int(weather.main.temp),
                        condition: weather.weather.first?.main ?? ""
                    )
                }
            }
        }
    }
    
    func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear":
            return "sun.max.fill"
        case "clouds":
            return "cloud.fill"
        case "rain":
            return "cloud.rain.fill"
        case "drizzle":
            return "cloud.drizzle.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "snow":
            return "cloud.snow.fill"
        case "mist", "fog", "haze":
            return "cloud.fog.fill"
        case "smoke":
            return "smoke.fill"
        case "dust", "sand":
            return "sun.dust.fill"
        case "ash":
            return "cloud.fill"
        case "squall":
            return "wind"
        case "tornado":
            return "tornado"
        default:
            return "cloud.fill"
        }
    }
}
