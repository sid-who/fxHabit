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
            self.streakCount.textColor = UIColor.init(red: 0.1, green: 0.6, blue: 0.4, alpha: 1)
        } else {
            self.streakCount.textColor = UIColor.init(red: 0.9, green: 0, blue: 0.1, alpha: 1)
        }
        
        streakCalculation(strcount: streakValue)
        // is this reload in the right spot?
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
        
        var dayCounter = strcount * -1
        let today = Date()
        let lastSaveDate = myDateForm.date(from: (PFUser.current()?["lastSaveDate"] as! String))!
        
        if (Calendar.current.compare(today, to: lastSaveDate, toGranularity: .day)) == .orderedSame {
            dayCounter += 1
        }
        
        let someDaysEarlier = Calendar.current.date(byAdding: .day, value: dayCounter, to: lastSaveDate)!
        streakDays.append(myDateForm.string(from: someDaysEarlier))
        dayCounter *= -1
        
        if strcount != 0 {
            for i in (1...dayCounter ){
                let nextDay = Calendar.current.date(byAdding: .day, value: i, to: someDaysEarlier)!
                let nextDayString = myDateForm.string(from: nextDay)
                streakDays.append(nextDayString)
            }
        }
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        let dateString: String = myDateForm.string(from: date)
        
        if self.streakDays.contains(dateString) {
            return UIColor.init(red: 0.1, green: 0.6, blue: 0.4, alpha: 1)
            
        } else {
            return nil
        }
    }
    
    
    /*
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM-dd-YYYY"
        let string = formatter.string(from: date)
    }
    */
}
