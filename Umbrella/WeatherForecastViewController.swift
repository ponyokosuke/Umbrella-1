import UIKit

class WeatherForecastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var maxPops: [Double] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherCell")
        tableView.dataSource = self
        tableView.reloadData()

        let testDate = Date()

        if let latitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
           let longitude = UserDefaults.standard.value(forKey: "longitude") as? Double {
            // APIキーの設定
            let apiKey = "fca09c676c26d6e1d67d6ac5fe12168d"

            getDTandPopValues(for: testDate, apiKey: apiKey, latitude: latitude, longitude: longitude) { [weak self] result in
                guard let self = self else {
                    return
                }

                switch result {
                case .success(let dtPopValues):
                    // 取得した配列を出力
                    for (dt, pop) in dtPopValues {
                        print("dt: \(dt), pop: \(pop)")
                    }

                    self.maxPops = self.findMaxPops(dtPopValues: dtPopValues)

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }

                case .failure(let error):
                    print("Error: \(error)")
                    // エラー処理を行う
                }
            }
        } else {
            print("Latitude or longitude not found in UserDefaults.")
            // エラー処理を行う
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maxPops.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherTableViewCell

        let currentDate = Date() // 現在の日付を取得
        let dayOffset = indexPath.row // インデックスに応じた日数を加算

        if let futureDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            let dateString = dateFormatter.string(from: futureDate)
            cell.datelistLabel?.text = dateString
        }

        let maxPop = maxPops[indexPath.row]
        let formattedPop = String(format: "%.0f%%", maxPop * 100) // パーセンテージに変換
        cell.poplistLabel?.text = formattedPop

        if maxPop <= 0.3 {
            cell.imagelistLabel?.image = UIImage(named: "sunnyumbrella")
        } else if maxPop <= 0.7 {
            cell.imagelistLabel?.image = UIImage(named: "cloudyumbrella")
        } else {
            cell.imagelistLabel?.image = UIImage(named: "rainyumbrella")
        }

        return cell
    }

    func getDTandPopValues(for date: Date, apiKey: String, latitude: Double, longitude: Double, completion: @escaping (Result<[(String, Double)], Error>) -> Void) {
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

                        var dtPopValues: [(String, Double)] = []

                        for hour in hourlyData {
                            if let dateString = hour["dt_txt"] as? String, let pop = hour["pop"] as? Double {
                                if let date = formatter.date(from: dateString), Calendar.current.isDate(date, inSameDayAs: date) {
                                    dtPopValues.append((dateString, pop))
                                }
                            }
                        }

                        if dtPopValues.count > 0 {
                            completion(.success(dtPopValues))
                        } else {
                            let error = NSError(domain: "No dt_txt and pop data available for the specified date", code: 0, userInfo: nil)
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

    func findMaxPops(dtPopValues: [(String, Double)]) -> [Double] {
        var maxPops: [Double] = []

        for i in stride(from: 0, to: dtPopValues.count, by: 8) {
            let endIndex = min(i + 8, dtPopValues.count)
            let subArray = dtPopValues[i..<endIndex]
            let maxPop = subArray.max(by: { $0.1 < $1.1 })?.1 ?? 0.0
            maxPops.append(maxPop)
        }

        return maxPops
    }
}
