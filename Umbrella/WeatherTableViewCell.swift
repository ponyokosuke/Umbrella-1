import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet var datelistLabel: UILabel!
    
    @IBOutlet weak var poplistLabel: UILabel!
    
    @IBOutlet weak var imagelistLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        datelistLabel = UILabel()
//        datelistLabel.textColor = UIColor.black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
