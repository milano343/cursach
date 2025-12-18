import CoreLocation
import SwiftUI
import UIKit
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var city: String = ""

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        print("LocationManager ініціалізовано")
    }

    func requestLocation() {
        print("requestLocation викликано, статус: \(manager.authorizationStatus.rawValue)")
        
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Запитуємо дозвіл...")
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Дозвіл є, отримуємо локацію")
            manager.requestLocation()
        case .restricted, .denied:
            print("Локація заблокована")
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Авторизація змінилась: \(manager.authorizationStatus.rawValue)")
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("Локація отримана: \(location.coordinate)")

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocode error:", error.localizedDescription)
                return
            }

            if let cityName = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.city = cityName
                    print("Визначене місто:", cityName)
                }
            } else {
                print("Місто не знайдено")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
}
