import SwiftUI

struct ContentView: View {

    @StateObject var vm = WeatherViewModel()
    @StateObject var favorites = FavoritesManager()
    @StateObject var locationManager = LocationManager()

    @State private var city: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // ===== ФОН =====
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0/255, green: 70/255, blue: 200/255),
                            Color(red: 135/255, green: 206/255, blue: 250/255)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 20) {

                            // УЛЮБЛЕНІ МІСТА
                            NavigationLink(
                                destination: FavoritesView(
                                    favorites: favorites,
                                    onSelect: { selectedCity in
                                        city = selectedCity
                                        loadWeather()
                                    }
                                )
                            ) {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Улюблені міста")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.85))
                                .cornerRadius(14)
                            }
                            .padding(.horizontal)

                            //  МОЯ ЛОКАЦІЯ
                            Button {
                                locationManager.requestLocation()
                            } label: {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Моя локація")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.85))
                                .cornerRadius(14)
                            }
                            .padding(.horizontal)
                            .onReceive(locationManager.$city) { newCity in
                                guard !newCity.isEmpty else { return }
                                city = newCity
                                loadWeather()
                            }

                            //ПОШУК
                            HStack {
                                TextField("Введіть місто...", text: $city)
                                    .padding()
                                    .background(Color.white.opacity(0.3))
                                    .cornerRadius(14)
                                    .foregroundColor(.white)
                                    .accentColor(.white)

                                Button {
                                    loadWeather()
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .font(.title2)
                                        .padding(12)
                                        .background(Color.blue.opacity(0.85))
                                        .foregroundColor(.white)
                                        .cornerRadius(14)
                                }
                            }
                            .padding(.horizontal)

                            // Завантаження
                            if isLoading {
                                Color.black.opacity(0.3)
                                    .ignoresSafeArea()

                                ProgressView("Завантаження...")
                                    .padding(24)
                                    .background(Color.white)
                                    .cornerRadius(16)
                            }

                            // Помилка
                            if let error = vm.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .padding(.top)
                            }

                            // КАРТКА ПОГОДИ
                            if let w = vm.weather {
                                VStack(spacing: 12) {

                                    Text(w.name)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)

                                    Text("\(Int(w.main.temp))°C")
                                        .font(.system(size: geo.size.width * 0.18))
                                        .fontWeight(.bold)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)

                                    Text(w.weather.first?.description.capitalized ?? "")
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
                                        .cornerRadius(14)
                                    }
                                    .padding(.top, 6)
                                }
                                .padding()
                                .frame(maxWidth: geo.size.width * 0.9)
                                .background(Color.white.opacity(0.92))
                                .cornerRadius(22)
                                .shadow(radius: 6)
                                .padding(.top)
                            }

                            // Прогноз
                            if !vm.forecast.isEmpty {
                                Text("Прогноз на 5 днів")
                                    .font(.headline)
                                    .foregroundColor(.white)
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
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding()
                                            .frame(width: geo.size.width * 0.28)
                                            .background(Color.white.opacity(0.9))
                                            .cornerRadius(16)
                                            .shadow(radius: 3)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            Spacer(minLength: 30)
                        }
                        .padding(.top)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 2) {
                            Text("Прогноз погоди")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Актуально прямо зараз")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .onAppear {
                    locationManager.requestLocation()
                }
            }
        }
    }

    // ===== ФУНКЦІЇ =====
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

