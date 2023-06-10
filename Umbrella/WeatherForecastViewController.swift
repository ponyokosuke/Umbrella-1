import UIKit

class WeatherForecastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherCell")
        tableView.dataSource = self
        tableView.reloadData()
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherCell")

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherTableViewCell

        let currentDate = Date() // 現在の日付を取得
        let dayOffset = indexPath.row // インデックスに応じた日数を加算

        if let futureDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            let dateString = dateFormatter.string(from: futureDate)
            //cell.datelistLabel.text = dateString // 日付をdatelistLabelに表示する
            cell.datelistLabel?.text = dateString

            if let latitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
               let longitude = UserDefaults.standard.value(forKey: "longitude") as? Double {
                getMaxPopValue(for: futureDate, apiKey: "YOUR_API_KEY", latitude: latitude, longitude: longitude) { result in
                    switch result {
                    case .success(let maxPop):
                        DispatchQueue.main.async {
                            cell.poplistLabel.text = "\(maxPop)" // 最大の"pop"をpoplistLabelに表示する
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                        // エラー処理を行う
                    }
                }
            }
        }

        return cell
    }

    func getMaxPopValue(for date: Date, apiKey: String, latitude: Double, longitude: Double, completion: @escaping (Result<Double, Error>) -> Void) {
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
                    print(json)
                    if let forecastData = json as? [String: Any], let hourlyData = forecastData["list"] as? [[String: Any]] {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                        var maxPop = 0.0

                        for hour in hourlyData {
                            if let dateString = hour["dt_txt"] as? String, let pop = hour["pop"] as? Double {
                                if let date = formatter.date(from: dateString), Calendar.current.isDate(date, inSameDayAs: date) {
                                    maxPop = max(maxPop, pop)
                                }
                            }
                        }

                        if maxPop > 0 {
                            completion(.success(maxPop))
                        } else {
                            let error = NSError(domain: "No pop data available for the specified date", code: 0, userInfo: nil)
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
}
