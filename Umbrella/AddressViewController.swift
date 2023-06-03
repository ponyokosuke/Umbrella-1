import UIKit
import CoreLocation

class AddressViewController: UIViewController {
    @IBOutlet weak var postcode1: UITextField!
    @IBOutlet weak var postcode2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let postcode = "\(postcode1.text!)\(postcode2.text!)"
        geocodeAddress(postcode: postcode) { (coordinate, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let coordinate = coordinate {
                print("緯度: \(coordinate.latitude)")
                print("経度: \(coordinate.longitude)")
            } else {
                print("緯度経度が見つかりませんでした。")
            }
        }
    }
}
    
    func geocodeAddress(postcode: String, completionHandler: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(postcode) { (placemarks, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completionHandler(nil, nil)
                return
            }
            
            if let location = placemark.location {
                completionHandler(location.coordinate, nil)
            } else {
                completionHandler(nil, nil)
            }
        }
    }
