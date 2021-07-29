//
//  ViewController.swift
//  busAlarmWithNavigate
//
//  Created by 羅珮珊 on 2021/7/27.
//

import UserNotifications
import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "TEST", style: UIBarButtonItem.Style.done, target: self, action: #selector(testAlert))
    }
    
    @objc func testAlert(){
        print("test")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if success{
                //success
                print("schedule")
                self.scheduleTest()
            }
            else {
                print("error")
            }
        })
    }
    
    func scheduleTest(){
        let content = UNMutableNotificationContent()
        content.title = "hello world"
        content.sound = .default
        content.body = "success"
        
        let targetDate = Date().addingTimeInterval(50)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour,.minute, .second], from: targetDate), repeats: false)
        
        let testRequest = UNNotificationRequest(identifier: "someLongID", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(testRequest, withCompletionHandler: {error in
            if error != nil {
                print("wrong")
            }
        })
    }
    
    
    @objc func addButtonClicked(){
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }

}

