//
//  CalendarViewController.swift
//  fxHabit
//
//  Created by Gurpreet Sidhu on 4/22/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import FSCalendar
import Parse

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var TodayLabel: UILabel!
    @IBOutlet weak var streakCount: UILabel!
    
    var streaks = [PFObject]()
    var thisUser : PFObject?
    
    var strCount = 0
    
    var streakDays : Array = [String]()
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var myDateForm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
       
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM-dd-YYYY"
        
        //let string = formatter.string(from: date)
        //TodayLabel.text = string
        
        // Do any additional setup after loading the view.
        let query = PFQuery(className:"_User")
        let currentUser = PFUser.current()
        //query.whereKey("objectId", equalTo:PFUser.current()!.objectId as Any)
        //query.limit = 1
        query.whereKey("username", equalTo:currentUser?.username)

        print(PFUser.current()!.objectId as Any)


        query.getFirstObjectInBackground {
          (object: PFObject?, error: Error?) -> Void in
          if error != nil || object == nil {

          } else {
            // The find succeeded.
            self.thisUser = object

            //print(self.thisUser?["streakValue"] as Any)
            self.strCount = (self.thisUser?["streakValue"])! as! Int
            self.streakCount.text = String(self.strCount)
            //self.streakCalculation(strcount: self.strCount)
            //self.secondAction()
            if(self.strCount >= 7){
                self.streakCount.textColor = UIColor.init(red: 0.1, green: 0.6, blue: 0.4, alpha: 1)
            } else {
                self.streakCount.textColor = UIColor.init(red: 0.9, green: 0, blue: 0.1, alpha: 1)
            }
          }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor?
    {
        //print(strCount)
        if let testArray : AnyObject? = UserDefaults.standard.object(forKey: "streaksArray") as AnyObject?{
            let readArray : [String] = testArray! as! [String]
            //print(readArray)
            streakDays = readArray
        }
        
        
        //streakDays.append("2020-04-13")
        let dateString: String = myDateForm.string(from: date)
        let date2 = Date()
        let dateString2: String = myDateForm.string(from: date2)
        //print(dateString2)
        
        if self.streakDays.contains(dateString) && dateString != dateString2{
//            return UIColor.green
            //return UIColor.init(red: 0.9, green: 0, blue: 0.1, alpha: 1)
            return UIColor.init(red: 0.1, green: 0.6, blue: 0.4, alpha: 1)
            
        } else {
            return nil
        }
    }
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor?
//    {
//
//        streakDays.append("2020-04-13")
//        let dateString: String = myDateForm.string(from: date)
//
//        if self.streakDays.contains(dateString){
//            return UIColor.green
//        } else {
//            return nil
//        }
//    }
    
    
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM-dd-YYYY"
        let string = formatter.string(from: date)
        print("\(string)")
        //TodayLabel.text = string
    }
    
//    func streakCalculation(strcount : Int){
//
//        //streakCount.text = String(strcount)
//
////        if(strcount >= 7){
////            streakCount.textColor = UIColor.init(red: 0.1, green: 0.6, blue: 0.4, alpha: 1)
////        } else {
////            streakCount.textColor = UIColor.init(red: 0.9, green: 0, blue: 0.1, alpha: 1)
////        }
//
//        let negativeDays = strcount * -1
//
//        let today = Date()
//        let someDaysEarlier = Calendar.current.date(byAdding: .day, value: negativeDays, to: today)!
//
//        print(myDateForm.string(from: someDaysEarlier))
//
//        streakDays.append(myDateForm.string(from: someDaysEarlier))
//
////        let testDay = Calendar.current.date(byAdding: .day, value: 1, to: someDaysEarlier)!
////        print(myDateForm.string(from:testDay))
//
//        //print(myDateForm.string(from: someDaysEarlier))
//        for i in (1...strcount){
//            let nextDay = Calendar.current.date(byAdding: .day, value: i, to: someDaysEarlier)!
//            //print(myDateForm.string(from: nextDay))
//            let nextDayString = myDateForm.string(from: nextDay)
//            print(nextDayString)
//            streakDays.append(nextDayString)
//        }
//
//    }
    
}
