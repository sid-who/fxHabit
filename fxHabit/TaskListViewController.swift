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
    
    var posts = [PFObject]()
    var individualPost : PFObject?
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Tasks")
        query.whereKey("author", equalTo:PFUser.current()!)
        query.limit = 15
        
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            } else {
                print("Error, can't load posts")
            }
        }
        backgroundWork()
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window!.rootViewController = loginViewController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell") as! TaskTableViewCell
        let post = posts[indexPath.row]
        cell.titleLabel.text = post["title"] as? String
        cell.descriptionLabel.text = post["description"] as? String
        
        let checked = post["checked"] as? Bool
        if checked == false {
            cell.checkmarkButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
            cell.checkmarkButton.addTarget(self, action: #selector(fireworks), for: .touchUpInside)
            cell.checkmarkButton.accessibilityIdentifier = post.objectId
        } else {
            cell.checkmarkButton.setImage(UIImage(systemName: "checkmark.rectangle.fill"), for: .normal)
            cell.checkmarkButton.accessibilityIdentifier = post.objectId
            cell.checkmarkButton.addTarget(self, action: #selector(fireworks), for: .touchUpInside)
        }
        
        return cell
    }
    
    @objc func fireworks(sender:UIButton) {
        let query = PFQuery(className:"Tasks")
        query.getObjectInBackground(withId: (sender.accessibilityIdentifier)!) { (post, error) in
            if error == nil {
                let checked = post!["checked"] as? Bool
                
                if checked! == false {
                    post!["checked"] = true
                } else if checked! == true {
                    post!["checked"] = false
                }
                
                post?.saveInBackground()
                self.viewDidAppear(true)
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewTaskSegue" {
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? ViewTaskViewController {
                targetController.task = individualPost
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // when user clicks on certain task, go to view task view controller
        individualPost = posts[indexPath.row]
        performSegue(withIdentifier: "ViewTaskSegue", sender: self)
    }
    
    func backgroundWork() {
        // Do any additional setup after loading the view.
        let query = PFQuery(className:"_User")
        let currentUser = PFUser.current()
        print(PFUser.current()?["streakValue"])
        //let somefuckingnumber = PFUser.current()?["streakValue"]
        //streakCalculation(strcount: somefuckingnumber as! Int)
        
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
            //self.streakCount.text = String(self.strCount)
            self.streakCalculation(strcount: self.strCount)
            //self.secondAction()
//            if(self.strCount >= 7){
//                self.streakCount.textColor = UIColor.init(red: 0.1, green: 0.6, blue: 0.4, alpha: 1)
//            } else {
//                self.streakCount.textColor = UIColor.init(red: 0.9, green: 0, blue: 0.1, alpha: 1)
//            }
          }
        }
    }
    
    func streakCalculation(strcount : Int){
        let strcount = strcount
        let negativeDays = strcount * -1
        
        let today = Date()
        let someDaysEarlier = Calendar.current.date(byAdding: .day, value: negativeDays, to: today)!
        
        
        streakDays.append(myDateForm.string(from: someDaysEarlier))
        
        for i in (1...strcount){
            let nextDay = Calendar.current.date(byAdding: .day, value: i, to: someDaysEarlier)!
            let nextDayString = myDateForm.string(from: nextDay)
            //print(nextDayString)
            streakDays.append(nextDayString)
        }
        
        let streaksArray = streakDays
        let defaults = UserDefaults.standard
        defaults.set(streaksArray, forKey: "streaksArray")
        let streakCountNumber = strCount
        defaults.set(streakCountNumber, forKey: "yourStreak")
    }
}
