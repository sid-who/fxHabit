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
    var entry : PFObject?
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadEntries()
    }
    
    func loadEntries() {
        let query = PFQuery(className:"Entries")
        query.whereKey("author", equalTo:PFUser.current()!)
        query.limit = 15
        
        query.findObjectsInBackground{ (entries, error) in
            if entries != nil {
                self.entries = entries!
                self.amountOfColors = 0
                self.colorTracker = []
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
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        
        if indexPath.row == 0 {
            cell.topConstraintForView.constant = 15
            self.tableView.rowHeight = 90 + 7.5;
        } else {
            cell.topConstraintForView.constant = 7.5
            self.tableView.rowHeight = 90;
        }
        
        let entry = entries[indexPath.row]
        cell.titleLabel.text = entry["title"] as? String
        cell.dateLabel.text = entry["date"] as? String
        
        if amountOfColors > 3 {
            amountOfColors = 0
        }
        
        cell.journalViewBlock.backgroundColor = taskColors[amountOfColors]
        colorTracker.append(amountOfColors)
        
        amountOfColors += 1
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewEntrySegue" {
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? ViewEntryViewController {
                targetController.entry = entry
                targetController.taskColor = sendThisColor
            }
        }
        
        if segue.identifier == "NewEntrySegue" {
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? NewEntryViewController {
                targetController.instanceOfA = self
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // when user clicks on certain task, go to view task view controller
        sendThisColor = []
        
        entry = entries[indexPath.row]
        sendThisColor.append(taskColors[colorTracker[indexPath.row]])
        
        if colorTracker[indexPath.row] == 3 {
            sendThisColor.append(taskColors[0])
        } else {
            sendThisColor.append(taskColors[colorTracker[indexPath.row] + 1])
        }
        
        performSegue(withIdentifier: "ViewEntrySegue", sender: self)
    }
    
    //
    // Swipe on a cell
    //
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let query = PFQuery(className:"Entries")
            query.whereKey("author", equalTo:PFUser.current()!)
            
            query.findObjectsInBackground{ (entries, error) in
                if entries != nil {
                    let deleteAlert = UIAlertController(title: "Are you sure you want to delete this task?", message: entries![indexPath.row]["title"] as? String, preferredStyle: UIAlertController.Style.alert)
                    
                    deleteAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
                        let entry = entries![indexPath.row]
                        entry.deleteInBackground()
                        self.loadEntries()
                        deleteAlert.dismiss(animated: true, completion: nil)
                    }))
                    deleteAlert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action) in
                        deleteAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(deleteAlert, animated: true, completion: nil)
                } else {
                    print("deleteJournale: Error, can't retrieve entries")
                }
            }
        }
    }
}
