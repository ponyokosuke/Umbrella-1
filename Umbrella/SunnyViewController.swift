import UIKit
import Foundation
import CoreLocation

class SunnyViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var rainyPercentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        // タイマーを使って定期的に日付を表示する
//        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//
//            self.printCurrentDate()
//        }
//
//        // メインループを開始してタイマーを実行する
//        RunLoop.main.add(timer, forMode: .common)
//
//        // メインスレッドを実行し続ける
//        RunLoop.main.run()
        printCurrentDate()
        fetchWeatherData(latitude: 35.6812, longitude: 139.7671, completion: { result in
            switch result{
            case .success(let temp):
                DispatchQueue.main.async {
                    self.temperatureLabel.text = temp
                }
                print(temp)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<String, Error>) -> Void) {
        let apiKey = "fca09c676c26d6e1d67d6ac5fe12168d"
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "WeatherAPIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data received"])
                completion(.failure(error))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(json)
                    if let main = json["main"] as? [String: Any],
                       let temperature = main["temp"] as? Double {
                        completion(.success(String(temperature-273)))
                    } else {
                        let error = NSError(domain: "WeatherAPIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    // 以下はUserDefaultsに保存されたlatitudeとlongitudeの値を読み取り、天気情報を取得する例です。

//    if let latitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
//       let longitude = UserDefaults.standard.value(forKey: "longitude") as? Double {
//        fetchWeatherData(latitude: latitude, longitude: longitude) { result in
//            switch result {
//            case .success(let weatherData):
//                print("Weather Data:\n\(weatherData)")
//            case .failure(let error):
//                print("Failed to fetch weather data: \(error.localizedDescription)")
//            }
//        }
//    } else {
//        print("Latitude and/or longitude not found in UserDefaults")
//    }
//
//    func getCityName(latitude: Double, longitude: Double, completion: @escaping (Result<String, Error>) -> Void) {
//        let location = CLLocation(latitude: latitude, longitude: longitude)
//        let geocoder = CLGeocoder()
//
//        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let placemark = placemarks?.first,
//                  let cityName = placemark.locality ?? placemark.subLocality ?? placemark.administrativeArea else {
//                let error = NSError(domain: "GeocodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "City name not found"])
//                completion(.failure(error))
//                return
//            }
//
//            completion(.success(cityName))
//        }
//    }

    // 以下はUserDefaultsに保存されたlatitudeとlongitudeの値を読み取り、市区町村を取得する例です。

//    if let latitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
//       let longitude = UserDefaults.standard.value(forKey: "longitude") as? Double {
//        getCityName(latitude: latitude, longitude: longitude) { result in
//            switch result {
//            case .success(let cityName):
//                print("City: \(cityName)")
//            case .failure(let error):
//                print("Failed to get city name: \(error.localizedDescription)")
//            }
//        }
//    } else {
//        print("Latitude and/or longitude not found in UserDefaults")
//    }

    func printCurrentDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        let currentDate = Date()
        let formattedDate = formatter.string(from: currentDate)
        dateLabel.text = formattedDate
        print("Current Date: \(formattedDate)")
    }

}
