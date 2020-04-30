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
    var pendings = [String]()
    var sents = [String]()
    var friends = [String]()
    var pCount = 0
    var sCount = 0
    var fCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"PendingFriends")
        query.whereKey("user", equalTo:PFUser.current()!)
        query.getFirstObjectInBackground { (list, error) in
            if list != nil {
                self.pendings = list!["pendingRequest"]! as! [String]
                self.sents = list!["sentRequest"]! as! [String]
                self.pCount = self.pendings.count
                self.sCount = self.sents.count
            } else {
                print("Error loading pending friends")
            }
        }
        
        let friendQuery = PFQuery(className: "FriendsList")
        friendQuery.whereKey("user", equalTo: PFUser.current()!)
        friendQuery.getFirstObjectInBackground { (list, error) in
            if list != nil {
                self.friends = list!["friends"]! as! [String]
                self.fCount = self.friends.count
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
    
    @objc func onAcceptButton(sender:UIButton) {
        // add friend to current user's friend list // WORKS
        let fQuery = PFQuery(className:"FriendsList")
        fQuery.whereKey("user", equalTo:PFUser.current()!)
        fQuery.getFirstObjectInBackground { (list, error) in
            if list != nil {
                self.friends = list!["friends"]! as! [String]
                self.friends.append(sender.accessibilityIdentifier!)
                list!["friends"] = self.friends
                list!.saveInBackground()
            } else {
                print("Error loading current user's friend list")
            }
        }
        
        // remove friend from current user pending list // WORKS
        let pQuery = PFQuery(className:"PendingFriends")
        pQuery.whereKey("user", equalTo:PFUser.current()!)
        pQuery.getFirstObjectInBackground { (list, error) in
            if list != nil {
                self.pendings = list!["pendingRequest"]! as! [String]
                self.pendings = self.pendings.filter { $0 != sender.accessibilityIdentifier! }
                list!["pendingRequest"] = self.pendings
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
                        self.friends = list!["friends"]! as! [String]
                        self.friends.append(PFUser.current()!.objectId!)
                        list!["friends"] = self.friends
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
                        self.pendings = list!["sentRequest"]! as! [String]
                        self.pendings = self.pendings.filter { $0 != PFUser.current()!.objectId! }
                        list!["sentRequest"] = self.pendings
                        list!.saveInBackground()
                    } else {
                        print("Error loading friend's pending list")
                    }
                }
            }
        }
        tableView.reloadData()
        super.viewDidAppear(true)
    }
    
    @objc func onRejectButton(sender:UIButton) {
        print(sender.accessibilityIdentifier!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendings.count + sents.count + friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if pCount > 0 {
            let pending = pendings[indexPath.row] as String
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFriendTableViewCell") as! PendingFriendTableViewCell
            let query = PFQuery(className: "_User")
            query.getObjectInBackground(withId: pending) { (pendingUser, error) in
                if error == nil {
                    cell.nameLabel.text = pendingUser!["username"] as? String
                    cell.acceptButton.accessibilityIdentifier = pending
                    cell.acceptButton.addTarget(self, action: #selector(self.onAcceptButton), for: .touchDown)
                    cell.rejectButton.accessibilityIdentifier = pending
                    cell.rejectButton.addTarget(self, action: #selector(self.onRejectButton), for: .touchDown)
                } else {
                    print("Error printing pending cells")
                }
            }
            pCount -= 1
            return cell
        } else if sCount > 0 {
            let sent = sents[indexPath.row] as String
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFriendTableViewCell") as! PendingFriendTableViewCell
            let query = PFQuery(className: "_User")
            query.getObjectInBackground(withId: sent) { (pendingUser, error) in
                if error == nil {
                    cell.friendRequestLabel.text = "Request sent to..."
                    cell.acceptButton.isHidden = true
                    cell.rejectButton.isHidden = true
                    cell.nameLabel.text = pendingUser!["username"] as? String
                } else {
                    print("Error printing sent request cells")
                }
            }
            sCount -= 1
            return cell
        } else {
            let friend = friends[indexPath.row] as String
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell") as! FriendTableViewCell
            let query = PFQuery(className: "_User")
            query.getObjectInBackground(withId: friend) { (friendUser, error) in
                if error == nil {
                    cell.nameLabel.text = friendUser!["username"] as? String
                    cell.finishedLabel.text = "No"
                    
                    let streak = friendUser!["streakValue"] as! Int
                    if (streak == 0) {
                        cell.streakLabel.text = "Streak = 0"
                    } else {
                        let stringStreak = String(streak)
                        cell.streakLabel.text = "Streak = " + stringStreak
                    }
                    
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
}
