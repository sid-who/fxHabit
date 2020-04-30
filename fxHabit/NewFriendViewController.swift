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
        } else {
            let query = PFQuery(className:"_User")
            query.whereKey("username", equalTo: usernameTextField.text!)
            query.getFirstObjectInBackground{ (userFound, error) in
                if userFound == nil {
                    self.errorLabel.text = "User with that name does not exist"
                } else {
                    // add new friend to user's pending list
                    let friendquery = PFQuery(className:"PendingFriends")
                    friendquery.whereKey("user", equalTo:PFUser.current()!)
                    friendquery.getFirstObjectInBackground { (list, error) in
                        if list != nil {
                            var friendslist = list!["friends"] as? [String]
                            friendslist?.append(userFound!.objectId!)
                            list!["friends"] = friendslist
                            list?.saveInBackground()
                        } else {
                            print("Error getting friends list")
                        }
                    }
                    
                    // add user's name to pending list for other user
                    let pendingquery = PFQuery(className: "PendingFriends")
                    pendingquery.whereKey("user", equalTo: userFound!)
                    pendingquery.getFirstObjectInBackground { (list, error) in
                        if list != nil {
                            var pendinglist = list!["friends"] as? [String]
                            pendinglist?.append((PFUser.current()?.objectId!)!)
                            list!["friends"] = pendinglist
                            list?.saveInBackground()
                        } else {
                            print("Error getting pending list")
                        }
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
