import SwiftUI

struct ContentView: View {

    @StateObject var vm = WeatherViewModel()
    @StateObject var favorites = FavoritesManager()
    @StateObject var locationManager = LocationManager()

    @State private var city: String = ""
    @State private var isLoading: Bool = false
    @State private var hasLoadedInitialLocation = false 
    @State private var citySuggestions: [String] = []
    @State private var showSuggestions: Bool = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
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
                                // Дозволяємо наступне оновлення локації
                                hasLoadedInitialLocation = false
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
                                // Завантажуємо тільки якщо це перший раз або користувач натиснув кнопку
                                if !hasLoadedInitialLocation {
                                    city = newCity
                                    loadWeather()
                                    hasLoadedInitialLocation = true
                                }
                            }

                            //ПОШУК
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    TextField("Введіть місто...", text: $city)
                                        .padding()
                                        .background(Color.white.opacity(0.3))
                                        .cornerRadius(14)
                                        .foregroundColor(.white)
                                        .accentColor(.white)
                                        .onChange(of: city) { newValue in
                                            updateSuggestions(for: newValue)
                                        }

                                    Button {
                                        showSuggestions = false
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
                                
                                // Підказки міст
                                if showSuggestions && !citySuggestions.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(citySuggestions, id: \.self) { suggestion in
                                            Button {
                                                city = suggestion
                                                showSuggestions = false
                                                loadWeather()
                                            } label: {
                                                Text(suggestion)
                                                    .foregroundColor(.primary)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                            }
                                            .background(Color.white.opacity(0.95))
                                            
                                            if suggestion != citySuggestions.last {
                                                Divider()
                                            }
                                        }
                                    }
                                    .cornerRadius(14)
                                    .shadow(radius: 3)
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

                                    Text(translateWeather(w.weather.first?.description ?? ""))
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

                                                Image(systemName: weatherIcon(for: item.weather.first?.main ?? ""))
                                                    .font(.title)
                                                    .foregroundColor(.blue)

                                                Text("\(Int(item.main.temp))°C")
                                                    .font(.title3)
                                                    .fontWeight(.semibold)

                                                Text(translateWeather(item.weather.first?.description ?? ""))
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
                    // Завантажуємо локацію тільки при першому відкритті
                    if !hasLoadedInitialLocation {
                        locationManager.requestLocation()
                    }
                }
            }
        }
    }

    // ФУНКЦІЇ 
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
    
    func updateSuggestions(for query: String) {
        guard query.count >= 2 else {
            citySuggestions = []
            showSuggestions = false
            return
        }
        
        let ukrainianCities = [
            "Київ", "Харків", "Одеса", "Дніпро", "Донецьк", "Запоріжжя",
            "Львів", "Кривий Ріг", "Миколаїв", "Маріуполь", "Луганськ",
            "Вінниця", "Макіївка", "Херсон", "Полтава", "Чернігів",
            "Черкаси", "Суми", "Житомир", "Хмельницький", "Чернівці",
            "Рівне", "Тернопіль", "Івано-Франківськ", "Луцьк", "Ужгород"
        ]
        
        let filtered = ukrainianCities.filter { city in
            city.lowercased().hasPrefix(query.lowercased())
        }
        
        citySuggestions = Array(filtered.prefix(5))
        showSuggestions = !citySuggestions.isEmpty
    }
    
    func translateWeather(_ description: String) -> String {
        let translations: [String: String] = [
            "clear sky": "ясне небо",
            "few clouds": "невелика хмарність",
            "scattered clouds": "розсіяні хмари",
            "broken clouds": "хмарно",
            "overcast clouds": "похмуро",
            "shower rain": "зливовий дощ",
            "rain": "дощ",
            "light rain": "невеликий дощ",
            "moderate rain": "помірний дощ",
            "heavy intensity rain": "сильний дощ",
            "thunderstorm": "гроза",
            "snow": "сніг",
            "light snow": "невеликий сніг",
            "mist": "імла",
            "fog": "туман",
            "haze": "серпанок",
            "smoke": "дим",
            "dust": "пил",
            "sand": "пісок",
            "drizzle": "мряка"
        ]
        
        return translations[description.lowercased()] ?? description.capitalized
    }
}
