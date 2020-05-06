//
//  FriendsListViewController.swift
//  fxHabit
//
//  Created by user163799 on 4/21/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse

class FriendsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    var combinedList = [String]()
    var pCount = 0
    var sCount = 0
    var fCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let username = PFUser.current()?.username
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.navigationItem.title = username! + "'s Friends"
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        tableView.delegate = self
        tableView.dataSource = self
        
        loadFriends()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadFriends()
    }
    
    //
    // Load friends and pending friends list
    //
    func loadFriends() {
        // Retrieve pending friends
        let query = PFQuery(className:"PendingFriends")
        query.whereKey("user", equalTo:PFUser.current()!)
        query.getFirstObjectInBackground { (list, error) in
            if list != nil {
                // empty list
                var pendings = [String]()
                var sents = [String]()
                self.combinedList = [String]()
                
                pendings = list!["pendingRequest"]! as! [String]
                sents = list!["sentRequest"]! as! [String]
                self.pCount = pendings.count
                self.sCount = sents.count
                
                for pend in pendings {
                    self.combinedList.append(pend)
                }
                for sent in sents {
                    self.combinedList.append(sent)
                }
            } else {
                print("Error loading pending friends")
            }
        }
        
        // Retrieve friend list
        let friendQuery = PFQuery(className: "FriendsList")
        friendQuery.whereKey("user", equalTo: PFUser.current()!)
        friendQuery.getFirstObjectInBackground { (list, error) in
            if list != nil {
                var friends = [String]()
                friends = list!["friends"]! as! [String]
                self.fCount = friends.count
                
                for friend in friends {
                    self.combinedList.append(friend)
                }
                self.tableView.reloadData()
            } else {
                print("Error loading friends list")
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
        return pCount + sCount + fCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if pCount > 0 {
            let pending = combinedList[indexPath.row] as String
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFriendTableViewCell") as! PendingFriendTableViewCell
            let query = PFQuery(className: "_User")
            query.getObjectInBackground(withId: pending) { (pendingUser, error) in
                if error == nil {
                    cell.nameLabel.text = pendingUser!["username"] as? String
                    cell.acceptButton.isHidden = false
                    cell.rejectButton.isHidden = false
                    
                    cell.acceptButton.accessibilityIdentifier = pending
                    cell.rejectButton.accessibilityIdentifier = pending
                    
                    cell.acceptButton.addTarget(self, action: #selector(self.onAcceptButton), for: .touchDown)
                    cell.rejectButton.addTarget(self, action: #selector(self.onRejectButton), for: .touchDown)
                } else {
                    print("Error printing pending cells")
                }
            }
            pCount -= 1
            return cell
        } else if sCount > 0 {
            let sent = combinedList[indexPath.row] as String
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFriendTableViewCell") as! PendingFriendTableViewCell
            let query = PFQuery(className: "_User")
            query.getObjectInBackground(withId: sent) { (pendingUser, error) in
                if error == nil {
                    cell.friendRequestLabel.text = "Request sent to..."
                    cell.nameLabel.text = pendingUser!["username"] as? String
                    
                    //Making the reject button a cancel button
                    cell.rejectButton.isHidden = false
                    cell.rejectButton.setTitle("Cancel", for: UIControl.State.init())
                    cell.rejectButton.accessibilityIdentifier = sent
                    cell.rejectButton.addTarget(self, action: #selector(self.cancelRequest), for: .touchDown)
                } else {
                    print("Error printing sent request cells")
                }
            }
            sCount -= 1
            return cell
        } else {
            let friend = combinedList[indexPath.row] as String
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell") as! FriendTableViewCell
            let query = PFQuery(className: "_User")
            query.getObjectInBackground(withId: friend) { (friendUser, error) in
                if error == nil {
                    cell.nameLabel.text = friendUser!["username"] as? String
                    
                    let streak = friendUser!["streakValue"] as! Int
                    if streak == 0 {
                        cell.streakLabel.text = "Streak = 0"
                    } else {
                        let stringStreak = String(streak)
                        cell.streakLabel.text = "Streak = " + stringStreak
                    }
                    
                    cell.moreButton.accessibilityIdentifier = friend
                    
                    /*
                    let lastSaveDate = friendUser!["lastSaveDate"] as? String
                    if lastSaveDate != self.getTodaysDate() {
                        cell.finishedLabel.text = "Not Done"
                    } else {
                        cell.finishedLabel.text = "Done!"
                    }
                    
                   */
                    
                    // I need the AlamofireImage pod :)
                    /*
                    let profileImageFile = friendUser!["profilePic"] as! PFFileObject
                    let profileUrlString = profileImageFile.url!
                    let profileUrl = URL(string: profileUrlString)!
                    
                    cell.profileImageView.af_setImage(withURL: profileUrl)
                    */
                } else {
                    print("Error printing friend cells")
                }
            }
            
            return cell
        }
    }
    
    //
    // When accepting a friend request
    //
    @objc func onAcceptButton(sender:UIButton) {
        // add friend to current user's friend list
        let fQuery = PFQuery(className:"FriendsList")
        fQuery.whereKey("user", equalTo:PFUser.current()!)
        fQuery.getFirstObjectInBackground { (list, error) in
            if list != nil {
                var friends = [String]()
                friends = list!["friends"]! as! [String]
                friends.append(sender.accessibilityIdentifier!)
                list!["friends"] = friends
                list?.pinInBackground()
                list!.saveInBackground()
            } else {
                print("Error loading current user's friend list")
            }
        }
        
        // remove friend from current user pending list
        let pQuery = PFQuery(className:"PendingFriends")
        pQuery.whereKey("user", equalTo:PFUser.current()!)
        pQuery.getFirstObjectInBackground { (list, error) in
            if list != nil {
                var pendings = [String]()
                pendings = list!["pendingRequest"]! as! [String]
                pendings = pendings.filter { $0 != sender.accessibilityIdentifier! }
                list!["pendingRequest"] = pendings
                list?.pinInBackground()
                list!.saveInBackground()
            } else {
                print("Error loading current user's pending list")
            }
        }
        
        let friendUser = PFQuery(className: "_User")
        friendUser.whereKey("objectId", equalTo: sender.accessibilityIdentifier!)
        friendUser.getFirstObjectInBackground { (friend, error) in
            if friend == nil {
                print("Error finding friend user")
            } else {
                // add current user to friend's friend list
                let f2Query = PFQuery(className:"FriendsList")
                f2Query.whereKey("user", equalTo: friend!)
                f2Query.getFirstObjectInBackground { (list, error) in
                    if list != nil {
                        var friends = [String]()
                        friends = list!["friends"]! as! [String]
                        friends.append(PFUser.current()!.objectId!)
                        list!["friends"] = friends
                        list?.pinInBackground()
                        list!.saveInBackground()
                    } else {
                        print("Error loading friend's friend list")
                    }
                }
                
                // remove current user from friend's pending list
                let p2Query = PFQuery(className:"PendingFriends")
                p2Query.whereKey("user", equalTo:friend!)
                p2Query.getFirstObjectInBackground { (list, error) in
                    if list != nil {
                        var pendings = [String]()
                        pendings = list!["sentRequest"]! as! [String]
                        pendings = pendings.filter { $0 != PFUser.current()!.objectId! }
                        list!["sentRequest"] = pendings
                        list?.pinInBackground()
                        list!.saveInBackground()
                        self.loadFriends()
                    } else {
                        print("Error loading friend's pending list")
                    }
                }
            }
        }
    }
    
    //
    // When rejecting a friend request 
    //
    @objc func onRejectButton(sender:UIButton) {
        // remove friend from current user pending list
        let pQuery = PFQuery(className:"PendingFriends")
        pQuery.whereKey("user", equalTo:PFUser.current()!)
        pQuery.getFirstObjectInBackground { (list, error) in
            if list != nil {
                var pendings = [String]()
                pendings = list!["pendingRequest"]! as! [String]
                pendings = pendings.filter { $0 != sender.accessibilityIdentifier! }
                list!["pendingRequest"] = pendings
                list?.pinInBackground()
                list!.saveInBackground()
            } else {
                print("Error loading current user's pending list")
            }
        }
        
        let friendUser = PFQuery(className: "_User")
        friendUser.whereKey("objectId", equalTo: sender.accessibilityIdentifier!)
        friendUser.getFirstObjectInBackground { (friend, error) in
            if friend == nil {
                print("Error finding friend user")
            } else {
                // remove current user from friend's pending list
                let p2Query = PFQuery(className:"PendingFriends")
                p2Query.whereKey("user", equalTo:friend!)
                p2Query.getFirstObjectInBackground { (list, error) in
                    if list != nil {
                        var pendings = [String]()
                        pendings = list!["sentRequest"]! as! [String]
                        pendings = pendings.filter { $0 != PFUser.current()!.objectId! }
                        list!["sentRequest"] = pendings
                        list?.pinInBackground()
                        list!.saveInBackground()
                        self.loadFriends()
                    } else {
                        print("Error loading friend's pending list")
                    }
                }
            }
        }
    }
    
    //
    // Canceling a request you sent
    //
    @objc func cancelRequest(sender:UIButton) {
        // remove friend from current user's sent list
        let pQuery = PFQuery(className:"PendingFriends")
        pQuery.whereKey("user", equalTo:PFUser.current()!)
        pQuery.getFirstObjectInBackground { (list, error) in
            if list != nil {
                var pendings = [String]()
                pendings = list!["sentRequest"]! as! [String]
                pendings = pendings.filter { $0 != sender.accessibilityIdentifier! }
                list!["sentRequest"] = pendings
                list?.pinInBackground()
                list!.saveInBackground()
            } else {
                print("Error loading current user's pending list")
            }
        }
        
        let friendUser = PFQuery(className: "_User")
        friendUser.whereKey("objectId", equalTo: sender.accessibilityIdentifier!)
        friendUser.getFirstObjectInBackground { (friend, error) in
            if friend == nil {
                print("Error finding friend user")
            } else {
                // remove current user from friend's pending list
                let p2Query = PFQuery(className:"PendingFriends")
                p2Query.whereKey("user", equalTo:friend!)
                p2Query.getFirstObjectInBackground { (list, error) in
                    if list != nil {
                        var pendings = [String]()
                        pendings = list!["pendingRequest"]! as! [String]
                        pendings = pendings.filter { $0 != PFUser.current()!.objectId! }
                        list!["pendingRequest"] = pendings
                        list?.pinInBackground()
                        list!.saveInBackground()
                        self.loadFriends()
                    } else {
                        print("Error loading friend's pending list")
                    }
                }
            }
        }
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
}
