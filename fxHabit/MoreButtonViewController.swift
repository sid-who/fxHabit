//
//  MoreButtonViewController.swift
//  fxHabit
//
//  Created by Yazmin Carrillo on 5/8/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse

class MoreButtonViewController: UIViewController {

    @IBOutlet weak var encourageButton: UIButton!
    @IBOutlet weak var removeFriendButton: UIButton!
    @IBOutlet weak var popupViewBlock: UIView!
    var friend = String()
    var instanceOfVCA:FriendsListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        print(friend)
    }
    
    func setupView() {
        encourageButton.layer.cornerRadius = 15
        removeFriendButton.layer.cornerRadius = 15
        popupViewBlock.layer.cornerRadius = 15
        popupViewBlock.layer.masksToBounds = true
    }
    
    @IBAction func onEncourageButton(_ sender: Any) {
        // Find friend user to edit their table
        let friendUser = PFQuery(className: "_User")
        friendUser.whereKey("objectId", equalTo: friend)
        friendUser.getFirstObjectInBackground { (friend, error) in
            if friend == nil {
                print("Error finding friend user")
            } else {
                // add current user to friend's encourageList
                let query = PFQuery(className:"FriendsList")
                query.whereKey("user", equalTo:friend!)
                query.getFirstObjectInBackground { (list, error) in
                    if list != nil {
                        var encourage = [String]()
                        encourage = list!["encourageList"] as! [String]
                        encourage.append(PFUser.current()!.username!)
                        list!["encourageList"] = encourage
                        list?.saveInBackground()
                        
                        let alert = UIAlertController(title: "Encouragement has been sent :)", message: "", preferredStyle: UIAlertController.Style.alert)
                        self.present(alert, animated: true, completion: nil)
                        
                        let when = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print("Error loading friend's pending list")
                    }
                }
            }
        }
    }
    
    @IBAction func onRemoveFriendButton(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Deleting Friend", message: "Are you sure you want to delete this friend?", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            // remove friend off current user list
            let query = PFQuery(className: "FriendsList")
            query.whereKey("user", equalTo: PFUser.current()!)
            query.getFirstObjectInBackground { (list, error) in
                if list != nil {
                    var friends = [String]()
                    friends = (list!["friends"] as? [String])!
                    friends = friends.filter { $0 != self.friend}
                    list!["friends"] = friends
                    list?.saveInBackground()
                } else {
                    print("onRemoveFriendButton: Error loading current user's pending list")
                }
            }
            
            // Find friend user to edit their table
            let friendUser = PFQuery(className: "_User")
            friendUser.whereKey("objectId", equalTo: self.friend)
            friendUser.getFirstObjectInBackground { (friend, error) in
                if friend == nil {
                    print("onRemoveFriendButton: Error finding friend user")
                } else {
                    // remove current user from friend's list
                    let query = PFQuery(className: "FriendsList")
                    query.whereKey("user", equalTo: friend!)
                    query.getFirstObjectInBackground { (list, error) in
                        var friends = [String]()
                        friends = list!["friends"] as! [String]
                        friends = friends.filter { $0 != PFUser.current()!.objectId!}
                        list!["friends"] = friends
                        list?.saveInBackground()
                    }
                }
            }
            
            let alert = UIAlertController(title: "Friend has been deleted", message: "", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when) {
                alert.dismiss(animated: true, completion: nil)
            }
            
            self.dismiss(animated: true, completion: nil)
            self.instanceOfVCA.viewDidAppear(true)
        }))
        deleteAlert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action) in
            deleteAlert.dismiss(animated: true, completion: nil)
        }))
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func onBackgroundButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onXButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
