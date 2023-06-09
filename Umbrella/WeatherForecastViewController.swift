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
            
        }
        
        return cell
    }

}
