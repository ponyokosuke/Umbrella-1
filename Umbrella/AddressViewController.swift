import UIKit

class AddressViewController: UIViewController {
    
    
    @IBOutlet weak var postcode1: UITextField!
    
    @IBOutlet weak var postcode2: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func savebutton(_ sender: Any) {
        let postcode = "\(postcode1.text!)\(postcode2.text!)"
        print("郵便番号: \(postcode)")
        
        getLatLongFromPostalCode(postalCode: postcode) { (latitude, longitude) in
                if let latitude = latitude, let longitude = longitude {
                    print("緯度: \(latitude), 経度: \(longitude)")

                    // 緯度と経度をUserDefaultsに保存
                    UserDefaults.standard.set(latitude, forKey: "latitude")
                    UserDefaults.standard.set(longitude, forKey: "longitude")

                    // 保存された緯度と経度の取得例
                    if let savedLatitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
                       let savedLongitude = UserDefaults.standard.value(forKey: "longitude") as? Double {
                        print("保存された緯度: \(savedLatitude), 経度: \(savedLongitude)")
                    } else {
                        print("保存された緯度と経度がありません。")
                    }
                } else {
                    print("緯度と経度が取得できませんでした。")
                }
            }
    }
    
    
    func getLatLongFromPostalCode(postalCode: String, completion: @escaping (Double?, Double?) -> Void) {
        let url = URL(string: "https://example.com/api/zipcode/\(postalCode)")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }

            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let latitude = json["latitude"] as? Double, let longitude = json["longitude"] as? Double {
                            completion(latitude, longitude)
                            return
                        }
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }

            completion(nil, nil)
        }

        task.resume()
    }

}

