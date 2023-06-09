import UIKit
import Foundation
import CoreLocation

class SunnyViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var rainypercentLabel: UILabel!
    
    @IBOutlet weak var whitebox: UIView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        whitebox.layer.cornerRadius = 25

        if let backgroundView = backgroundImage {
                view.addSubview(backgroundView)
                view.sendSubviewToBack(backgroundView)
            }
        }
    
    override func viewDidAppear(_ animated: Bool) {
        printCurrentDate()
        
        if let latitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
           let longitude = UserDefaults.standard.value(forKey: "longitude") as? Double {
            fetchWeatherData1(latitude: latitude, longitude: longitude) { result in
                switch result{
                case .success(let temp):
                    DispatchQueue.main.async {
                        let temperatureWithUnit = temp + "℃"
                        self.temperatureLabel.text = temperatureWithUnit
                    }
                    print(temp)
                case .failure(let error):
                    print(error)
                }
            }
            
            fetchWeatherData2(latitude: latitude, longitude: longitude) { result in
                switch result {
                case .success(let description):
                    DispatchQueue.main.async {
                        self.weatherLabel.text = self.getWeatherStatus(from: description)
                    }
                    print(description)
                case .failure(let error):
                    print(error)
                }
            }
            
            fetchWeatherData2(latitude: latitude, longitude: longitude) { result in
                switch result {
                case .success(let description):
                    DispatchQueue.main.async {
                        let weatherStatus = self.getWeatherStatus(from: description)
                        self.weatherLabel.text = weatherStatus
                        
                        if weatherStatus == "晴れ" {
                            self.backgroundImage.image = UIImage(named: "sunny")
                        } else if weatherStatus == "曇り" {
                            self.backgroundImage.image = UIImage(named: "cloudy")
                        } else {
                            self.backgroundImage.image = UIImage(named: "rainy")
                        }
                    }
                    UserDefaults.standard.set(description, forKey: "WeatherDescription")
                    print(description)
                case .failure(let error):
                    print(error)
                }
            }
            
            getPopValue(apiKey: "fca09c676c26d6e1d67d6ac5fe12168d", latitude: latitude, longitude: longitude) { result in
                switch result {
                case .success(let averagePop):
                    DispatchQueue.main.async {
                        let realPop = (averagePop * 1000).rounded()/10
                        self.rainypercentLabel.text = "\(realPop)%"
                    }
                    print("Rainy percentage: \(averagePop)%")
                case .failure(let error):
                    print("Error:", error.localizedDescription)
                }
            }
            
            fetchCityFromCoordinates(latitude: latitude, longitude: longitude) { result in
                switch result {
                case .success(let city):
                    DispatchQueue.main.async {
                        self.locationLabel.text = city
                    }
                    print("City: \(city)")
                case .failure(let error):
                    print("Failed to fetch city: \(error.localizedDescription)")
                }
            }
        } else {
            print("Latitude and/or longitude not found in UserDefaults")
        }
        
    }
    
    func fetchWeatherData1(latitude: Double, longitude: Double, completion: @escaping (Result<String, Error>) -> Void) {
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
                    if let main = json["main"] as? [String: Any],
                       let temperature = main["temp"] as? Double {
                        let roundedTemperature = Int(round(temperature - 273.15)) // 温度を四捨五入して整数に変換
                        completion(.success(String(roundedTemperature)))
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
    
    
    func fetchWeatherData2(latitude: Double, longitude: Double, completion: @escaping (Result<String, Error>) -> Void) {
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
                    if let weatherArray = json["weather"] as? [[String: Any]],
                       let weather = weatherArray.first,
                       let description = weather["description"] as? String  {
                        completion(.success(description))
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
    
    func getWeatherStatus(from description: String) -> String {
        switch description {
        case "clear sky":
            return "晴れ"
        case "scattered clouds", "broken clouds", "overcast clouds", "few clouds":
            return "曇り"
        case "mist", "smoke", "haze", "sand/dust whirls", "fog", "sand", "dust", "volcanic ash", "squalls", "tornado":
            return "霧"
        case "light snow", "snow", "heavy snow", "sleet", "light shower sleet", "shower sleet", "light rain and snow", "rain and snow", "light shower snow", "shower snow", "heavy shower snow":
            return "雪"
        case "light rain", "moderate rain", "heavy intensity rain", "very heavy rain", "extreme rain", "freezing rain", "light intensity shower rain", "heavy intensity shower rain", "ragged shower rain", "shower rain", "rain":
            return "雨"
        case "light intensity drizzle", "drizzle", "heavy intensity drizzle", "light intensity drizzle rain", "drizzle rain", "heavy intensity drizzle rain", "shower rain and drizzle", "heavy shower rain and drizzle", "shower drizzle":
            return "小雨"
        case "thunderstorm with light rain", "thunderstorm with rain", "thunderstorm with heavy rain", "light thunderstorm", "thunderstorm", "heavy thunderstorm", "ragged thunderstorm", "thunderstorm with light drizzle", "thunderstorm with drizzle", "thunderstorm with heavy drizzle":
            return "雷雨"
        default:
            return "その他"
        }
    }
    
//    func getPopValue(apiKey: String, latitude: Double, longitude: Double, completion: @escaping (Result<Double, Error>) -> Void) {
//        let baseURL = "https://api.openweathermap.org/data/2.5/forecast"
//        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
//
//        guard let url = URL(string: urlString) else {
//            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
//            completion(.failure(error))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                let error = NSError(domain: "Invalid response", code: 0, userInfo: nil)
//                completion(.failure(error))
//                return
//            }
//
//            if let data = data {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
//                    if let forecastData = json as? [String: Any], let hourlyData = forecastData["list"] as? [[String: Any]] {
//                        var totalPop = 0.0
//                        var totalCount = 0
//
//                        for hour in hourlyData {
//                            if let pop = hour["pop"] as? Double {
//                                totalPop += pop
//                                totalCount += 1
//                            }
//                        }
//
//                        let averagePop = totalPop / Double(totalCount)
//                        completion(.success(averagePop))
//                    } else {
//                        let error = NSError(domain: "Forecast data not available", code: 0, userInfo: nil)
//                        completion(.failure(error))
//                    }
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//        }
//
//        task.resume()
//    }
    
    func getPopValue(apiKey: String, latitude: Double, longitude: Double, completion: @escaping (Result<Double, Error>) -> Void) {
        let baseURL = "https://api.openweathermap.org/data/2.5/forecast"
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "Invalid response", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let forecastData = json as? [String: Any], let hourlyData = forecastData["list"] as? [[String: Any]] {
                        let currentTime = Date()

                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                        var popSum = 0.0
                        var popCount = 0

                        for hour in hourlyData {
                            if let dateString = hour["dt_txt"] as? String, let pop = hour["pop"] as? Double {
                                if let date = formatter.date(from: dateString), date.timeIntervalSince(currentTime) <= 3 * 3600 {
                                    popSum += pop
                                    popCount += 1
                                }
                            }
                        }

                        if popCount > 0 {
                            let averagePop = popSum / Double(popCount)
                            completion(.success(averagePop))
                        } else {
                            let error = NSError(domain: "No pop data available for the current time range", code: 0, userInfo: nil)
                            completion(.failure(error))
                        }
                    } else {
                        let error = NSError(domain: "Forecast data not available", code: 0, userInfo: nil)
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }


    func fetchCityFromCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Result<String, Error>) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first else {
                let error = NSError(domain: "GeocoderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Placemark not found"])
                completion(.failure(error))
                return
            }
            
            if let locality = placemark.locality {
                completion(.success(locality))
            } else {
                let error = NSError(domain: "GeocoderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Locality not found"])
                completion(.failure(error))
            }
        }
    }

    func printCurrentDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let currentDate = Date()
        let formattedDate = formatter.string(from: currentDate)
        dateLabel.text = formattedDate
        print("Current Date: \(formattedDate)")
    }
    
    func printCurrentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let currentTime = formatter.string(from: Date())
        print("Current time: \(currentTime)")
    }

}
