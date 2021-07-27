//
//  DetailsVC.swift
//  busAlarmWithNavigate
//
//  Created by 羅珮珊 on 2021/7/27.
//

import UIKit

class DetailsVC: UIViewController {

    @IBOutlet weak var busID: UITextField!
    @IBOutlet weak var departureStop: UIButton!
    @IBOutlet weak var destinationStop: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func updataBusDirection(_ sender: Any) {
        print("")
    }
    
    
    @IBAction func setAlarm(_ sender: Any) {
        print("set busAlarm")
    }
}
