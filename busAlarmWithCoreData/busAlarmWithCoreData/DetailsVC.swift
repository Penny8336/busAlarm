//
//  DetailsVC.swift
//  busAlarmWithNavigate
//
//  Created by 羅珮珊 on 2021/7/27.
//

import UIKit
import CryptoKit
import Foundation
import CoreData

func getTimeString() -> String {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "EEE, dd MMM yyyy HH:mm:ww zzz"
    dateFormater.locale = Locale(identifier: "en_US")
    dateFormater.timeZone = TimeZone(secondsFromGMT: 0)
    let time = dateFormater.string(from: Date())
    return time
}

let appId = "a981984e5cae4a34bf47f91567f1a207"...
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
    var seletedStop: String?
    var alarmTime = ""
    var direction = ""
    var stopID: String?
    var routes = [[String]]()
    var routesDict: Dictionary<String, String> = [:]
    var tempRoute = ["select the bus"]
    var departureRoute = Array<String>()
    var destinationRoute = Array<String>()
    
    @IBOutlet weak var busID: UITextField!
    @IBOutlet weak var directionControl: UISegmentedControl!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        //Core Data
        
//        if chosenPainting != "" {
//
//            saveButton.isHidden = true
//
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            let context = appDelegate.persistentContainer.viewContext
//
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
//            let idString = chosenPaintingId?.uuidString
//            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
//            fetchRequest.returnsObjectsAsFaults = false
//
//            do {
//               let results = try context.fetch(fetchRequest)
//
//                if results.count > 0 {
//
//                    for result in results as! [NSManagedObject] {
//
//                        if let busID = result.value(forKey: "busID") as? String {
//    //                        nameText.text = name
//                        }
//
//                        if let stopID = result.value(forKey: "artist") as? String {
//    //                        artistText.text = artist
//                        }
//
//                        if let alarmTime = result.value(forKey: "year") as? Int {
//    //                        yearText.text = String(year)
//                        }
//
//
//                    }
//                }
//
//            } catch{
//                print("error")
//            }
//
//
//        } else {
//            saveButton.isHidden = false
//            saveButton.isEnabled = false
////            nameText.text = ""
////            artistText.text = ""
////            yearText.text = ""
//        }
    
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
                        self.routesDict[stop.Zh_tw] = stop.StopUID
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
    
    @IBAction func setTime(_ sender: Any) {
        let dateFormatter = DateFormatter()

//        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short

        let strDate = dateFormatter.string(from: timePicker.date)
        alarmTime = strDate
    }
    
    @IBAction func setAlarm(_ sender: Any) {
        print("set busAlarm","butID",enterBusID,"stop", stopID,"time",alarmTime)

        //core data
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//
//        let newSetting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
//
//        //Attributes
//
//        newSetting.setValue(enterBusID, forKey: "busID")
//        newSetting.setValue(stopID, forKey: "stopID")
//        newSetting.setValue(alarmTime, forKey: "alarmTime")
//
//        do {
//            try context.save()
//            print("success")
//        } catch {
//            print("error")
//        }
//
//        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
//        self.navigationController?.popViewController(animated: true)
    }
}

//@IBAction func saveButtonClicked(_ sender: Any) {
//
//
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    let context = appDelegate.persistentContainer.viewContext
//
//    let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
//
//    //Attributes
//
//    newPainting.setValue(nameText.text!, forKey: "name")
//    newPainting.setValue(artistText.text!, forKey: "artist")
//
//    if let year = Int(yearText.text!) {
//        newPainting.setValue(year, forKey: "year")
//    }
//
//    newPainting.setValue(UUID(), forKey: "id")
//
//    let data = imageView.image!.jpegData(compressionQuality: 0.5)
//
//    newPainting.setValue(data, forKey: "image")
//
//    do {
//        try context.save()
//        print("success")
//    } catch {
//        print("error")
//    }
//
//
//    NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
//    self.navigationController?.popViewController(animated: true)
//
//}

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

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var seletedStop = tempRoute[row]
        stopID = routesDict[seletedStop]
        
    }
    

}

