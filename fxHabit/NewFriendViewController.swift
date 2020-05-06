//
//  NewFriendViewController.swift
//  fxHabit
//
//  Created by user163799 on 4/21/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse

class NewFriendViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.text = ""
    }
    
    @IBAction func onAddButton(_ sender: Any) {
        if usernameTextField.text == "" {
            errorLabel.text = "Missing username"
        } else if usernameTextField.text == PFUser.current()?.username {
            errorLabel.text = "You can't add yourself"
        } else {
            //
            // Look for user with username entered
            //
            let query = PFQuery(className:"_User")
            query.whereKey("username", equalTo: usernameTextField.text!)
            query.getFirstObjectInBackground{ (userFound, error) in
                if userFound == nil {
                    self.errorLabel.text = "User with that name does not exist"
                } else {
                    //
                    // Check if user is already friends with userFound
                    //
                    let checkFriendsList = PFQuery(className: "FriendsList")
                    checkFriendsList.whereKey("user", equalTo: PFUser.current()!)
                    checkFriendsList.getFirstObjectInBackground { (fList, error) in
                        if fList != nil {
                            let friendsList = fList!["friends"] as? [String]
                            if (friendsList?.contains(userFound!.objectId!))! {
                                self.errorLabel.text = "You are already friends with this user."
                            } else {
                                //
                                // Check if user has already sent a friend request to userFound
                                //
                                let checkPendingList = PFQuery(className: "PendingFriends")
                                checkPendingList.whereKey("user", equalTo: PFUser.current()!)
                                checkPendingList.getFirstObjectInBackground { (userPList, error) in
                                    if userPList != nil {
                                        var sentRequestList = userPList!["sentRequest"] as? [String]
                                        if (sentRequestList?.contains(userFound!.objectId!))! {
                                            self.errorLabel.text = "You already sent a request to this user."
                                        } else {
                                            //
                                            // Add new friend to user's pending list in sentRequest column
                                            //
                                            sentRequestList?.append(userFound!.objectId!)
                                            userPList!["sentRequest"] = sentRequestList
                                            userPList?.saveInBackground()
                                            
                                            //
                                            // Add current user to pending list for other user in pendingRequest column
                                            //
                                            let pendingquery = PFQuery(className: "PendingFriends")
                                            pendingquery.whereKey("user", equalTo: userFound!)
                                            pendingquery.getFirstObjectInBackground { (otherPList, error) in
                                                if otherPList != nil {
                                                    var pendinglist = otherPList!["pendingRequest"] as? [String]
                                                    pendinglist?.append((PFUser.current()?.objectId!)!)
                                                    otherPList!["pendingRequest"] = pendinglist
                                                    otherPList?.saveInBackground()
                                                    self.dismiss(animated: true, completion: nil)
                                                } else {
                                                    self.errorLabel.text = "Found user does not have a pending list. Please check database."
                                                }
                                            }
                                        }
                                    } else {
                                        self.errorLabel.text = "Current user does not have a pending list. Please check database."
                                    }
                                }
                            }
                        } else {
                            self.errorLabel.text = "Current user does not have a friends list. Please check database."
                        }
                    }
                }
            }
        }
    }
    @IBAction func onXButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    } 
}
