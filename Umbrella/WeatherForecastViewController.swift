import UIKit

class WeatherForecastViewController: UIViewController {
    
    @IBOutlet weak var date: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 7

      }

}
