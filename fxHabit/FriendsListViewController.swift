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
                self.tableView.reloadData()
            } else {
                print("Error loading pending friends")
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
        return pendings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFriendTableViewCell") as! PendingFriendTableViewCell
        
        let pending = pendings[indexPath.row]
        
        let query = PFQuery(className: "_User")
        query.getObjectInBackground(withId: pending) { (pendingUser, error) in
            if error == nil {
                cell.nameLabel.text = pendingUser!["username"] as? String
            } else {
                print("Error")
            }
        }
        
        return cell
    }
}
