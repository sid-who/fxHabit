//
//  JournalViewController.swift
//  fxHabit
//
//  Created by Yazmin Carrillo on 4/8/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse

class JournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var entries = [PFObject]()
    var entry = [PFObject()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Entries")
        query.whereKey("author", equalTo:PFUser.current()!)
        query.limit = 15
        
        query.findObjectsInBackground{ (entries, error) in
            if entries != nil {
                self.entries = entries!
                self.tableView.reloadData()
            } else {
                print("Error, can't load entries")
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
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalTableViewCell") as! JournalTableViewCell
        let entryx = entries[indexPath.row]
        cell.titleLabel.text = entryx["title"] as? String
        cell.dateLabel.text = entryx["date"] as? String
        
        return cell
    }
}
