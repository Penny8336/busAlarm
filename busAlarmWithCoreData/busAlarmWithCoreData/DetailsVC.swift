//
//  DetailsVC.swift
//  busAlarmWithNavigate
//
//  Created by 羅珮珊 on 2021/7/27.
//

import UIKit
import CryptoKit
import Foundation

func getTimeString() -> String {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "EEE, dd MMM yyyy HH:mm:ww zzz"
    dateFormater.locale = Locale(identifier: "en_US")
    dateFormater.timeZone = TimeZone(secondsFromGMT: 0)
    let time = dateFormater.string(from: Date())
    return time
}

let appId = "a981984e5cae4a34bf47f91567f1a207"
let appKey = "Zc9QZL0LwVx1RBKwC08ufWxQXFM"
let xdate = getTimeString()
let signDate = "x-date: \(xdate)"
let key = SymmetricKey(data: Data(appKey.utf8))
let hmac = HMAC<SHA256>.authenticationCode(for: Data(signDate.utf8), using: key)
let base64HmacString = Data(hmac).base64EncodedString()
let authorization = """
hmac username="\(appId)", algorithm="hmac-sha256", headers="x-date", signature="\(base64HmacString)"
"""

var departure = ""
var destination = ""

class DetailsVC: UIViewController {

    var enterBusID = ""
    var routes = [[String]]()
    var tempRoute = ["temp"]
    var departureRoute = Array<String>()
    var destinationRoute = Array<String>()
    
    @IBOutlet weak var busID: UITextField!
    @IBOutlet weak var directionControl: UISegmentedControl!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func updataBusDirection(_ sender: Any) {
        enterBusID = busID.text!
        print("update Direction \(enterBusID)")
        let directionUrl = URL(string:"https://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/\(enterBusID)?$top=30&$format=JSON")!
        var request = URLRequest(url: directionUrl)

        request.setValue(xdate, forHTTPHeaderField: "x-date")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let data = data {
                self.parseJsonData(data: data)

//                改變departure and destination
                DispatchQueue.main.async{
                    self.directionControl.setTitle( "\(departure)" , forSegmentAt: 0 )
                    self.directionControl.setTitle( "\(destination)" , forSegmentAt: 1 )
                }
            }
        }.resume()
        
        let routeUrl = URL(string:"https://ptx.transportdata.tw/MOTC/v2/Bus/DisplayStopOfRoute/City/Taipei/\(enterBusID)?$top=30&$format=JSON")!
        var routeRequest = URLRequest(url: routeUrl)

        
        routeRequest.setValue(xdate, forHTTPHeaderField: "x-date")
        routeRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: routeRequest) { (data, response, error) in
            if let error = error {
                print(error)
                print("error")
                return
            }
            
            
            if let data = data {
//                self.tempDate = self.parseRouteJsonData(data: data)
                let decoder = JSONDecoder()
                let busRoutes = try! decoder.decode([busRouteStore].self, from: data)
//                print(type(of:busRoutes))
                print(busRoutes.count)
                for direc in 0...1 {
                    for stop in busRoutes[direc].Stops{
                        if direc == 0 {
                            self.departureRoute.append(stop.Zh_tw)
                        }
                        else{
                            self.destinationRoute.append(stop.Zh_tw)
                        }
                    }
                }
                DispatchQueue.main.async{
                    self.tempRoute = self.departureRoute
                    self.pickerView.reloadAllComponents()
                    self.pickerView.selectRow(2, inComponent: 0, animated: true)
                }
            }
        }.resume()
        

    }
    
    func parseJsonData(data: Data){

        let decoder = JSONDecoder()

        let loan = try! decoder.decode([busDirections].self, from: data)
        for user in loan {
            departure = user.DepartureStopNameZh
            destination = user.DestinationStopNameZh
            print("for")
            print(departure, destination)
        }
    }
    
    
    
    @IBAction func pickerSelectionChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                self.tempRoute = self.departureRoute
            case 1:
                self.tempRoute = self.destinationRoute

            default:
                 break
             }
        
        pickerView.reloadAllComponents()
        pickerView.selectRow(2, inComponent: 0, animated: true)

    }
    
    
    
    @IBAction func setAlarm(_ sender: Any) {
        print("set busAlarm")
    }
}

extension DetailsVC: UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tempRoute.count
    }
    
    
}

extension DetailsVC: UIPickerViewDelegate{
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tempRoute[row]
    }
}
