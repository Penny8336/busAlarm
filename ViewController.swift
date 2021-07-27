//
//  ViewController.swift
//  busAlarm
//
//  Created by 羅珮珊 on 2021/7/17.
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

//func findDirection(busID:String){
//
//    let url = URL(string:"https://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/307?$top=30&$format=JSON")!
//    var request = URLRequest(url: url)
//
//    request.setValue(xdate, forHTTPHeaderField: "x-date")
//    request.setValue(authorization, forHTTPHeaderField: "Authorization")
//    URLSession.shared.dataTask(with: request) { (data, response, error) in
//        if let data = data {
//            let content = String(data: data, encoding: .utf8) ?? ""
//
//            struct Loan: Codable {
//                var DepartureStopNameZh: String
//                var DestinationStopNameZh: String
//
//                enum CodingKeys: String, CodingKey {
//                    case DepartureStopNameZh
//                    case DestinationStopNameZh
//
//                }
//
//
//
//                init(from decoder: Decoder) throws {
//                    let values = try decoder.container(keyedBy: CodingKeys.self)
//
//
//                    DepartureStopNameZh = try values.decode(String.self, forKey: .DepartureStopNameZh)
//                    DestinationStopNameZh = try values.decode(String.self, forKey: .DestinationStopNameZh)
//                }
//            }
//
//            let decoder = JSONDecoder()
//            let jsonData = content.data(using: .utf8)!
//            let loan = try! decoder.decode([Loan].self, from: jsonData)
//            for user in loan {
//                departure = user.DepartureStopNameZh
//                destination = user.DestinationStopNameZh
//                print("for")
//                print(departure, destination)
//                DispatchQueue.main.async{
//                    self.departureStop.setTitle( "\(departure)" , for: .normal )
//                    self.destinationStop.setTitle( "\(destination)" , for: .normal )
//
//                    }
//            }
//
//        }
//
//    }.resume()
//}


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

class ViewController: UIViewController {

    var enterBusID = ""
    @IBOutlet weak var busID: UITextField!
    @IBOutlet weak var departureStop: UIButton!
    @IBOutlet weak var destinationStop: UIButton!
    @IBOutlet weak var direction: UIButton!
    @IBOutlet weak var stopPicker: UIPickerView!
    @IBOutlet weak var confrimStopButton: UIButton!
    
    var tempDate = [String]()
    var routes = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        stopPicker.dataSource = self
        stopPicker.delegate = self

    }

    @IBAction func updateDirection(_ sender: Any) {
        enterBusID = busID.text!
        print("update Direction \(enterBusID)")
        let url = URL(string:"https://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/\(enterBusID)?$top=30&$format=JSON")!
        var request = URLRequest(url: url)

        
        request.setValue(xdate, forHTTPHeaderField: "x-date")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let data = data {
                self.parseJsonData(data: data)

                DispatchQueue.main.async{
                    self.departureStop.setTitle( "\(departure)" , for: .normal )
                    self.destinationStop.setTitle( "\(destination)" , for: .normal )
                }
            }
        }.resume()
    }
    
    func parseJsonData(data: Data){

        let decoder = JSONDecoder()

        let loan = try! decoder.decode([Loan].self, from: data)
        for user in loan {
            departure = user.DepartureStopNameZh
            destination = user.DestinationStopNameZh
            print("for")
            print(departure, destination)
        }
    }
    
    
    @IBAction func chooseDeparture(_ sender: Any) {
        print("\(enterBusID)departure\(departure)")
        let url = URL(string:"https://ptx.transportdata.tw/MOTC/v2/Bus/DisplayStopOfRoute/City/Taipei/\(enterBusID)?$top=30&$format=JSON")!
        var request = URLRequest(url: url)

        
        request.setValue(xdate, forHTTPHeaderField: "x-date")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                print("error")
                return
            }
            
            if let data = data {
//                self.tempDate = self.parseRouteJsonData(data: data)
                let decoder = JSONDecoder()
                let busRoutes = try! decoder.decode([busRouteStore].self, from: data)
                for user in busRoutes {
                    for stop in user.Stops{
        //                print(stop.Zh_tw)
                        self.routes.append(stop.Zh_tw)
                    }
                }
            }
        }.resume()
        self.stopPicker.reloadAllComponents()
        self.stopPicker.selectRow(0, inComponent: 0, animated: true)
    }
    

    

    @IBAction func chooseDestination(_ sender: Any) {
        print("non")
        print(routes)
    }
    
    @IBAction func confirmStop(_ sender: Any) {
        print("confirm the Stop")
    }
    
}

extension ViewController: UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("tempDate.count")
        print(routes.count)
        return routes.count
    }
    
    
}

extension ViewController: UIPickerViewDelegate{
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return routes[row]
    }
}
