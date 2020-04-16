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
}
