//
//  TaskViewController.swift
//  fxHabit
//
//  Created by Yazmin Carrillo on 4/8/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    var tasks = [PFObject]()
    var individualPost : PFObject?
    
    var streaks = [PFObject]()
    var thisUser : PFObject?
    
    /* MARK: Remove */
    
    /*
    var strCount = 0
    var streakDays : Array = [String]()
    */
     
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    
    /*LOOKIE HERE*/fileprivate lazy var myDateForm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    
    //
    // For changing post colors 
    //
    let taskColors = [UIColor(displayP3Red: 0.09, green: 0.39, blue: 0.49, alpha: 0.7), UIColor(displayP3Red: 0.15, green: 0.68, blue: 0.69, alpha: 0.7), UIColor(displayP3Red: 0.95, green: 0.82, blue: 0.36, alpha: 0.7), UIColor(displayP3Red: 0.93, green: 0.58, blue: 0.29, alpha: 0.7)]
    var amountOfColors = Int()
    var colorTracker = [Int]()
    var sendThisColor = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.rowHeight = 90;
        tableView.delegate = self
        tableView.dataSource = self

        //backgroundWork()
        checkIfStreakIsBroken()
        loadTasks()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadTasks()
    }
    
    //
    // Initially loads the posts
    //
    func loadTasks() {
        let query = PFQuery(className:"Tasks")
        query.whereKey("author", equalTo:PFUser.current()!)
        query.limit = 15
        
        query.findObjectsInBackground{ (tasks, error) in
            if tasks != nil {
                self.tasks = tasks!
                self.amountOfColors = 0
                self.colorTracker = []
                self.tableView.reloadData()
            } else {
                print("Error, can't load posts")
            }
        }
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window!.rootViewController = loginViewController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //
    // For displaying the task cells
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell") as! TaskTableViewCell
        let task = tasks[indexPath.row]
        cell.titleLabel.text = task["title"] as? String
        cell.descriptionLabel.text = task["description"] as? String
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        
        if amountOfColors > 3 {
            amountOfColors = 0
        }
        
        let checked = task["checked"] as? Bool
        if checked == false{
            cell.checkmarkButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
            cell.cellView.backgroundColor = taskColors[amountOfColors]
            colorTracker.append(amountOfColors)
            
            cell.checkmarkButton.accessibilityIdentifier = task.objectId
            cell.checkmarkButton.addTarget(self, action: #selector(checkmarkTask), for: .touchDown)
        } else {
            cell.checkmarkButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            cell.cellView.backgroundColor = taskColors[amountOfColors].withAlphaComponent(1.0)
            colorTracker.append(amountOfColors)
            
            cell.checkmarkButton.accessibilityIdentifier = task.objectId
            cell.checkmarkButton.addTarget(self, action: #selector(checkmarkTask), for: .touchDown)
        }
        
        amountOfColors += 1
        
        return cell
    }
    
    //
    // Target action for buttons on each task
    // When checkmark is clicked, task's boolean value will be set to true/false
    // Let's user "check" and "uncheck" each task
    //
    @objc func checkmarkTask(sender:UIButton) {
        let query = PFQuery(className:"Tasks")
        query.getObjectInBackground(withId: (sender.accessibilityIdentifier)!) { (post, error) in
            if error == nil {
                let checked = post!["checked"]! as? Bool
                
                if checked == false {
                    post!["checked"] = true
                } else if checked == true {
                    post!["checked"] = false
                }
                post?.pinInBackground()
                post?.saveEventually()
                self.checkCheckmarks()
                self.loadTasks()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    //
    // Checks if all tasks have been checked
    // If so, alert displays asking if they are done for the day
    // If yes, day will be added to their streak and checkmarks will be reset
    //
    func checkCheckmarks() {
        var allDone = false
        
        let query = PFQuery(className: "Tasks")
        
        /* MARK: Remove */
        
        //query.fromLocalDatastore()
        query.whereKey("author", equalTo:PFUser.current()!)
        query.findObjectsInBackground{ (tasks, error) in
            if tasks != nil {
                for task in tasks! {
                    let checked = task["checked"] as? Bool
                    
                    if checked == false {
                        return
                    } else {
                        allDone = true
                    }
                }
                
                if allDone == true {
                    self.createAlert(title: "Tasks Are All Checked!", message: "Looks like you have checked all your tasks for the day! Awesome! Are you ready to submit your day!?")
                } else {
                    return
                }
            } else {
                print("Error, can't retrieve tasks: checkCheckmark()")
            }
        }
    }
    
    //
    // Once user has all tasks checked, alert will be displayed asking if they are done for the day
    // Function will increment streak value on user profile and save the calendar date.
    //
    func createAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // YES BUTTON - RESET CHECKMARKS
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
            // Get user's profile to update information
            let query = PFQuery(className: "_User")
            query.getObjectInBackground(withId: PFUser.current()!.objectId!) { (currentUser, error) in
                if currentUser != nil {
                    self.resetCheckMarks()
                    let lastSaveDate = currentUser!["lastSaveDate"] as! String
                    
                    //if they have already saved for the day it won't allow them to save again
                    if lastSaveDate == self.getTodaysDate() {
                        // display alert that they already saved for the day
                        let errorAlert = UIAlertController(title: "Uh Oh", message: "Looks like you have already saved for today. Come back again tomorrow to perform your tasks :)", preferredStyle: UIAlertController.Style.alert)
                        
                        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                            errorAlert.dismiss(animated: true, completion: nil)
                            self.loadTasks()
                        }))
                        self.present(errorAlert, animated: true, completion: nil)
                    } else {
                        currentUser?.incrementKey("streakValue")
                        currentUser!["lastSaveDate"] = self.getTodaysDate()
                        currentUser?.saveInBackground()
                        
                        let successAlert = UIAlertController(title: "Good Job!", message: "You did it! Great going, let's keep up the hard work :)", preferredStyle: UIAlertController.Style.alert)
                        
                        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                            successAlert.dismiss(animated: true, completion: nil)
                            self.loadTasks()
                        }))
                        self.present(successAlert, animated: true, completion: nil)
                    }
                } else {
                    print("Error pulling up user information: createAlert")
                }
            }
        }))
        
        // NO BUTTON - DO NOTHING
        alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //
    // Get's todays date to save when updating streak
    //
    func getTodaysDate() -> String{
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let result = formatter.string(from: currentDate)
        return result
    }
    
    //
    // Get yesterday's date to see if streak is broken
    //
    func getYesterdaysDate() -> String{
        let yesterday = Date.yesterday
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: yesterday)
        
        return result
    }
    
    func checkIfStreakIsBroken() {
        let query = PFQuery(className: "_User")
        query.getObjectInBackground(withId: PFUser.current()!.objectId!) { (currentUser, error) in
            if currentUser != nil {
                if currentUser!["lastSaveDate"] == nil {
                    return
                } else {
                    let lastStreakDay = currentUser!["lastSaveDate"] as! String
                    
                    if lastStreakDay == "" {
                        return
                    }
                    
                    if (lastStreakDay != self.getYesterdaysDate()) && (lastStreakDay != self.getTodaysDate()) {
                        currentUser!["streakValue"] = 0
                        currentUser!["lastSaveDate"] = ""
                        currentUser?.saveInBackground()
                        self.resetCheckMarks()
                        
                        let errorAlert = UIAlertController(title: "Uh Oh", message: "Looks like you missed a day in your streak :(", preferredStyle: UIAlertController.Style.alert)
                        
                        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                            errorAlert.dismiss(animated: true, completion: nil)
                            self.loadTasks()
                        }))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            } else {
                print("Error getting current user: checkIfStreakIsBroken()")
            }
        }
    }
    
    //
    // Resets the checkmark for each task individually, called recursively from checkCheckmarks()
    //
    func resetCheckMarks() {
        let tasksQuery = PFQuery(className: "Tasks")
        tasksQuery.whereKey("author", equalTo:PFUser.current()!)
        tasksQuery.findObjectsInBackground{ (tasks, error) in
            for task in tasks! {
                let query = PFQuery(className: "Tasks")
                query.getObjectInBackground(withId: task.objectId!) { (individualTask, error) in
                    if individualTask != nil {
                        individualTask!["checked"] = false
                        individualTask?.saveInBackground()
                    } else {
                        print("Error retrieving individual task: resetCheckMarks()")
                    }
                }
            }
        }
        
        loadTasks()
    }
    
    
    //
    // Sends individual task to ViewTaskViewController to be displayed
    // Runs 'prepare' function before performing segue
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewTaskSegue" {
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? ViewTaskViewController {
                targetController.task = individualPost
                targetController.taskColor = sendThisColor
            }
        }
    }
    
    //
    // Segue to ViewTaskViewController when task is selected
    // Get a detailed view of the selected task
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // when user clicks on certain task, go to view task view controller
        sendThisColor = []
        
        individualPost = tasks[indexPath.row]
        sendThisColor.append(taskColors[colorTracker[indexPath.row]])
        
        if colorTracker[indexPath.row] == 3 {
            sendThisColor.append(taskColors[0])
        } else {
            sendThisColor.append(taskColors[colorTracker[indexPath.row] + 1])
        }
        performSegue(withIdentifier: "ViewTaskSegue", sender: self)
    }
    
    
    /* MARK: Remove */
    
    /*
    func backgroundWork() {
        // Do any additional setup after loading the view.
        let query = PFQuery(className:"_User")
        let currentUser = PFUser.current()
        query.whereKey("username", equalTo:currentUser?.username! as Any)
        
        print(PFUser.current()!.objectId as Any)


        query.getFirstObjectInBackground {
          (object: PFObject?, error: Error?) -> Void in
          if error != nil || object == nil {
            
          } else {
            // The find succeeded.
            self.thisUser = object
            self.strCount = (self.thisUser?["streakValue"])! as! Int
            self.streakCalculation(strcount: self.strCount)
          }
        }
    }
    
    func streakCalculation(strcount : Int){
        let strcount = strcount
        let negativeDays = strcount * -1
        
        let today = Date()
        let someDaysEarlier = Calendar.current.date(byAdding: .day, value: negativeDays, to: today)!
        
        
        streakDays.append(myDateForm.string(from: someDaysEarlier))
        
        /*LOOKIE HERE**///myDateForm.string(from: someDaysEarlier)
        
        if strcount != 0 {
            for i in (1...strcount){
                let nextDay = Calendar.current.date(byAdding: .day, value: i, to: someDaysEarlier)!
                let nextDayString = myDateForm.string(from: nextDay)
                //print(nextDayString)
                streakDays.append(nextDayString)
            }
        }
        
        let streaksArray = streakDays
        let defaults = UserDefaults.standard
        defaults.set(streaksArray, forKey: "streaksArray")
        let streakCountNumber = strCount
        defaults.set(streakCountNumber, forKey: "yourStreak")
    }
     */
}
     

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
}
