import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet var datelistLabel: UILabel!
    
    @IBOutlet weak var poplistLabel: UILabel!
    
    @IBOutlet weak var imagelistLabel: UIImageView!
    
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 10
        cellView.layer.shadowColor = UIColor.black.cgColor //影の色を決める
        cellView.layer.shadowOpacity = 0.15 //影の色の透明度
        cellView.layer.shadowRadius = 3 //影のぼかし
        cellView.layer.shadowOffset = CGSize(width: 4, height: 4) //影の方向　width、heightを負の値にすると上の方に影が表示される
//        datelistLabel.font = UIFont(name:"AvenirNext-Heavy",size: 40)
//        poplistLabel.font = UIFont(name:"AvenirNext-Heavy",size: 40)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
