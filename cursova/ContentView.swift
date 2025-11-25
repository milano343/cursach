import SwiftUI

struct ContentView: View {

    @StateObject var vm = WeatherViewModel()
    @StateObject var favorites = FavoritesManager()

    @State private var city: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                // Кнопка переходу до улюблених міст
                NavigationLink(destination:
                    FavoritesView(favorites: favorites, onSelect: { selectedCity in
                        city = selectedCity
                        loadWeather()
                    })
                ) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Улюблені міста")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // --- Поле пошуку ---
                HStack {
                    TextField("Введіть місто...", text: $city)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    Button {
                        loadWeather()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .padding(12)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                // --- Індикатор завантаження ---
                if isLoading {
                    ProgressView("Завантаження...")
                        .padding()
                }

                // --- Ерор ---
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top)
                }

                // --- КАРТКА ПОГОДИ ---
                if let w = vm.weather {
                    VStack(spacing: 10) {

                        Text(w.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("\(Int(w.main.temp))°C")
                            .font(.system(size: 80))
                            .fontWeight(.bold)

                        Text(w.weather.first?.description ?? "")
                            .font(.title3)
                            .foregroundColor(.gray)

                        Button {
                            favorites.add(city: w.name)
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Додати в улюблені")
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.85))
                            .cornerRadius(12)
                        }
                        .padding(.top, 6)

                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }

                // --- ПРОГНОЗ ---
                if !vm.forecast.isEmpty {
                    Text("Прогноз на 5 днів")
                        .font(.headline)
                        .padding(.top)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(vm.forecast.prefix(20), id: \.dt) { item in
                                VStack(spacing: 8) {

                                    Text(formatDate(item.dt))
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Text("\(Int(item.main.temp))°C")
                                        .font(.title3)
                                        .fontWeight(.semibold)

                                    Text(item.weather.first?.description ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                }
                                .padding()
                                .frame(width: 110)
                                .background(Color(.systemGray5))
                                .cornerRadius(14)
                                .shadow(radius: 3)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .navigationTitle("Прогноз погоди")
        }
    }

    // --- ФУНКЦІЇ ---

    func loadWeather() {
        guard !city.isEmpty else { return }
        vm.errorMessage = nil
        isLoading = true

        Task {
            await vm.loadWeather(city: city)
            isLoading = false
        }
    }

    func formatDate(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM HH:mm"
        return formatter.string(from: date)
    }
}
