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
    var streakDays = [String]()
    var colorCounter = 0
    
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
        
        let streakValue:Int = PFUser.current()?["streakValue"]! as! Int
        
        streakCount.text = String(streakValue)
        
        if(streakValue >= 7){
            self.streakCount.textColor = UIColor.init(red: 0.1, green: 0.45, blue: 0.8, alpha: 0.9)
        } else {
            self.streakCount.textColor = UIColor.init(red: 0.7, green: 0.4, blue: 0.0, alpha: 0.5)
        }
        
        streakCalculation(strcount: streakValue)
        calendar.appearance.todayColor = UIColor.init(red: 0.1, green:0.6, blue: 0.7, alpha: 0.5)
        
        calendar.appearance.eventSelectionColor = UIColor.green
        
        calendar.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window!.rootViewController = loginViewController
    }
    
    
    func streakCalculation(strcount : Int) {
        
        if(strcount > 0)
        {
            var dayCounter = strcount * -1
            dayCounter += 1
            
            let lastSaveDate = myDateForm.date(from: (PFUser.current()?["lastSaveDate"] as! String))!
            
            let someDaysEarlier = Calendar.current.date(byAdding: .day, value: dayCounter, to: lastSaveDate)!
            streakDays.append(myDateForm.string(from: someDaysEarlier))
            dayCounter *= -1
            
            if strcount != 0 {
                for i in (0...dayCounter ){
                    let nextDay = Calendar.current.date(byAdding: .day, value: i, to: someDaysEarlier)!
                    let nextDayString = myDateForm.string(from: nextDay)
                    streakDays.append(nextDayString)
                }
            }
        }
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {

        let dateString: String = myDateForm.string(from: date)

        if self.streakDays.contains(dateString) {
            if colorCounter == 0 {
                colorCounter += 1
                return UIColor.init(red: 0.09, green: 0.39, blue: 0.49, alpha: 0.7)
            }
            else if colorCounter == 1 {
                colorCounter += 1
                return UIColor.init(red: 0.15, green: 0.68, blue: 0.69, alpha: 0.7)
            }
            else if colorCounter == 2 {
                colorCounter += 1
                return UIColor.init(red: 0.95, green: 0.82, blue: 0.36, alpha: 0.7)
            }
            else if colorCounter == 3 {
                colorCounter += 1
                return UIColor.init(red: 0.93, green: 0.58, blue: 0.29, alpha: 0.7)
            }
            else {
                colorCounter = 0
                return UIColor.init(red: 0.1, green: 0.45, blue: 0.8, alpha: 0.9)
            }
        } else {
            return nil
        }
    }
}
