import UIKit

class WeatherForecastViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.reloadData()
        
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherCell")

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherTableViewCell
        
        let currentDate = Date() // 現在の日付を取得
        let dayOffset = indexPath.row // インデックスに応じた日数を加算
        
        if let futureDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            let dateString = dateFormatter.string(from: futureDate)
            cell.datelistLabel.text = dateString // 日付をdatelistLabelに表示する
            
            let latitude = UserDefaults.standard.value(forKey: "latitude") as? Double
            let longitude = UserDefaults.standard.value(forKey: "longitude") as? Double
            
            fetchRainProbability(latitude: latitude, longitude: longitude) { result in
                switch result {
                case .success(let rainPercentage):
                    DispatchQueue.main.async {
                        if indexPath.row == tableView.indexPath(for: cell)?.row {
                            cell.popLabel.text = "\(rainPercentage)%"
                        }
                    }
                    print("降水確率: \(rainPercentage)%")
                case .failure(let error):
                    print("エラー: \(error.localizedDescription)")
                }
            }
        }
        
        return cell
    }
    
    func fetchRainProbability(latitude: Double?, longitude: Double?, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let latitude = latitude, let longitude = longitude else {
            let error = NSError(domain: "LocationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Latitude or longitude is not available"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "http://weather.livedoor.com/forecast/webservice/json/v1?city=\(latitude),\(longitude)")!
        
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
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                print(json)
                
                if let forecasts = json["forecasts"] as? [[String: Any]], let todayForecast = forecasts.first {
                    if let telop = todayForecast["telop"] as? String {
                        if telop.contains("雨") {
                            if let chanceOfRain = todayForecast["chanceOfRain"] as? [String: Any], let rainPercentage = chanceOfRain["T06_12"] as? Int {
                                completion(.success(rainPercentage))
                                return
                            }
                        }
                    }
                }
                
                let error = NSError(domain: "WeatherAPIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No rain data available"])
                completion(.failure(error))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

//import UIKit
//
//class WeatherForecastViewController: UIViewController, UITableViewDataSource {
//
//    @IBOutlet weak var tableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        tableView.dataSource = self
//        tableView.reloadData()
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 7
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WeatherTableViewCell
//
//        let currentDate = Date() // 現在の日付を取得
//        let dayOffset = indexPath.row // インデックスに応じた日数を加算
//
//        if let futureDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate) {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM/dd"
//            let dateString = dateFormatter.string(from: futureDate)
//            cell.datelistLabel.text = dateString // 日付をdatelistLabelに表示する
//        }
//
//        return cell
//    }
//}

