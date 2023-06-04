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
                if !coordinate.latitude.isNaN && !coordinate.longitude.isNaN {
                    UserDefaults.standard.set(coordinate.latitude, forKey: "latitude")
                    UserDefaults.standard.set(coordinate.longitude, forKey: "longitude")
                    print("緯度: \(coordinate.latitude)")
                    print("経度: \(coordinate.longitude)")
                    
                    // UserDefaultsの変更を即時に反映させる
                    UserDefaults.standard.synchronize()
                } else {
                    print("緯度と経度が見つかりませんでした。")
                }
            } else {
                print("緯度経度が見つかりませんでした。")
            }
        }
        self.dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UserDefaultsから緯度と経度を取得して出力する
        if let latitude = UserDefaults.standard.object(forKey: "latitude") as? Double,
            let longitude = UserDefaults.standard.object(forKey: "longitude") as? Double {
            print("保存された緯度: \(latitude)")
            print("保存された経度: \(longitude)")
        } else {
            print("保存された緯度と経度はありません。")
        }
    }

    
//    @IBAction func saveButton(_ sender: Any) {
//        let postcode = "\(postcode1.text!)\(postcode2.text!)"
//        geocodeAddress(postcode: postcode) { (coordinate, error) in
//            if let error = error {
//                print("Geocoding error: \(error.localizedDescription)")
//                return
//            }
//
//            if let coordinate = coordinate {
//                if !coordinate.latitude.isNaN && !coordinate.longitude.isNaN {
//                    let userDefaults = UserDefaults.standard
//                    userDefaults.set(coordinate.latitude, forKey: "latitude")
//                    userDefaults.set(coordinate.longitude, forKey: "longitude")
//                    print("緯度: \(coordinate.latitude)")
//                    print("経度: \(coordinate.longitude)")
//
//                    // UserDefaultsの変更を即時に反映させる
//                    userDefaults.synchronize()
//                } else {
//                    print("緯度と経度が見つかりませんでした。")
//                }
//            } else {
//                print("緯度経度が見つかりませんでした。")
//            }
//        }
//    }


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
