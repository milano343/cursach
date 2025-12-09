import SwiftUI

struct ContentView: View {
    
    @StateObject var vm = WeatherViewModel()
    @StateObject var favorites = FavoritesManager()
    @StateObject var locationManager = LocationManager()
    
    @State private var city: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0/255, green: 70/255, blue: 200/255),
                        Color(red: 135/255, green: 206/255, blue: 250/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    
                    // Кнопка переходу до улюблених міст
                    NavigationLink(
                        destination: FavoritesView(favorites: favorites, onSelect: { selectedCity in
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
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // кнопка гео
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
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .onReceive(locationManager.$city) { newCity in
                        guard !newCity.isEmpty else { return }
                        city = newCity
                        loadWeather()
                    }
                    
                    // --- Поле пошуку ---
                    HStack {
                        TextField("Введіть місто...", text: $city)
                            .padding()
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .accentColor(.white)
                        
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
                    
                    if isLoading {
                        ProgressView("Завантаження...")
                            .padding()
                            .foregroundColor(.white)
                    }
                    
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
                                .foregroundColor(.black)
                            
                            Text("\(Int(w.main.temp))°C")
                                .font(.system(size: 80))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
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
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
                    
                    // --- ПРОГНОЗ ---
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
                                            .foregroundColor(.black)
                                        Text(item.weather.first?.description ?? "")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .frame(width: 110)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(14)
                                    .shadow(radius: 3)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Прогноз погоди")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
            }
            .onAppear {
                // Запитуємо дозвіл на геолокацію при запуску
                locationManager.requestLocation()
            }
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
