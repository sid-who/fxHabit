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
        
        let streakValue:Int = PFUser.current()?["streakValue"]! as! Int
        
        streakCount.text = String(streakValue)
        
        if(streakValue >= 7){
            self.streakCount.textColor = UIColor.init(red: 0.1, green: 0.6, blue: 0.4, alpha: 1)
        } else {
            self.streakCount.textColor = UIColor.init(red: 0.9, green: 0, blue: 0.1, alpha: 1)
        }
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
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
    
        if let testArray : AnyObject = UserDefaults.standard.object(forKey: "streaksArray") as AnyObject?{
            let readArray : [String] = testArray as! [String]
            streakDays = readArray
        }
        
        let dateString: String = myDateForm.string(from: date)
        let date2 = Date()
        let dateString2: String = myDateForm.string(from: date2)
        
        if self.streakDays.contains(dateString) && dateString != dateString2 {
            return UIColor.init(red: 0.1, green: 0.6, blue: 0.4, alpha: 1)
            
        } else {
            return nil
        }
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM-dd-YYYY"
        let string = formatter.string(from: date)
    }
}
