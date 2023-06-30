import UIKit

class WeatherForecastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var maxPops: [Double] = []
    var latitude: Double = 24.2867
    var longitude: Double = 153.9807
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()

        let testDate = Date()

        if let storedLatitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
           let storedLongitude = UserDefaults.standard.value(forKey: "longitude") as? Double {
            latitude = storedLatitude
            longitude = storedLongitude

            // キャッシュからデータを取得
            if let cachedData = getCachedData() {
                handleAPIResult(result: .success(cachedData))
            } else {
                // APIキーの設定
                let apiKey = "d608cfc1b1575d9f5288e0265d67fe91"
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
            }
        } else {
            print("Latitude or longitude not found in UserDefaults.")
            // エラー処理を行う
        }
    }

    func fetchDataFromAPI() {
        // APIキーの設定
        let apiKey = "d608cfc1b1575d9f5288e0265d67fe91"
        
        let testDate = Date() // 追加

        getDTandPopValues(for: testDate, apiKey: apiKey, latitude: latitude, longitude: longitude) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let dtPopValues):
                // キャッシュにデータを保存
                self.cacheData(dtPopValues: dtPopValues)
                
                self.handleAPIResult(result: .success(dtPopValues))

            case .failure(let error):
                print("Error: \(error)")
                // エラー処理を行う
            }
        }
    }
    
    func handleAPIResult(result: Result<[(String, Double)], Error>) {
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
    
    @objc func userDefaultsDidChange(_ notification: Notification) {
        // 緯度または経度が変更された場合のみ新しいデータを取得
        if let storedLatitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
           let storedLongitude = UserDefaults.standard.value(forKey: "longitude") as? Double,
           (latitude != storedLatitude || longitude != storedLongitude) {

            // 緯度と経度を更新
            latitude = storedLatitude
            longitude = storedLongitude

            // キャッシュをクリア
            clearCachedData()

            // APIを呼び出して新しいデータを取得
            fetchDataFromAPI()
        }
    }
    
    func getCachedData() -> [(String, Double)]? {
        if let data = UserDefaults.standard.array(forKey: "cachedData") as? [[String: Any]] {
            return data.compactMap { dict in
                guard let dt = dict["dt"] as? String, let pop = dict["pop"] as? Double else {
                    return nil
                }
                return (dt, pop)
            }
        }
        return nil
    }

    func cacheData(dtPopValues: [(String, Double)]) {
        let cachedData = dtPopValues.map { (dt, pop) -> [String: Any] in
            return ["dt": dt, "pop": pop]
        }
        UserDefaults.standard.set(cachedData, forKey: "cachedData")
    }


    func clearCachedData() {
        UserDefaults.standard.removeObject(forKey: "cachedData")
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115.0 // セルの高さを設定
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 8
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
        UserDefaults.standard.set(maxPop, forKey: "maxPop")
        let formattedPop = String(format: "%.0f%%", maxPop * 100) // パーセンテージに変換
        cell.poplistLabel?.text = formattedPop

        if maxPop <= 0.3 {
            cell.imagelistLabel?.image = UIImage(named: "sunnyumbrella")
        } else if maxPop <= 0.7 {
            cell.imagelistLabel?.image = UIImage(named: "cloudyumbrella 1")
        } else {
            cell.imagelistLabel?.image = UIImage(named: "rainyumbrella")
        }
        
        if maxPop <= 0.3 {
            cell.cellView.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 1) // rgb(n,n,n)=#87CEEB
        } else if maxPop <= 0.7 {
            cell.cellView.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1) // rgb(n,n,n)=#D3D3D3
        } else {
            cell.cellView.backgroundColor = UIColor(red: 65/255, green: 105/255, blue: 225/255, alpha: 1) // rgb(n,n,n)=#4169E1
        }

        roundCorners(for: cell, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)

        return cell
    }

    func roundCorners(for view: UIView, corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // UserDefaultsの値が更新された際に再度APIリクエストを送信する
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange(_:)), name: UserDefaults.didChangeNotification, object: nil)
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
