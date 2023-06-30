//
//  AlarmViewController.swift
//  Umbrella
//
//  Created by 山下幸助 on 2023/06/30.
//

import UIKit

class AlarmViewController: UIViewController {
    
    @IBOutlet weak var alarmTableView: UITableView!
    @IBOutlet weak var Picker: UIDatePicker!
    
    var time: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func save1Button(_ sender: Any) {
        time = "\(Picker.date)"
        print(time)
        self.dismiss(animated: true)
    }
    
    @IBAction func back1Button(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

}
