//
//  ViewTaskViewController.swift
//  fxHabit
//
//  Created by Yazmin Carrillo on 4/9/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse

class ViewTaskViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var task : PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = task?["title"]! as? String
        descriptionLabel.text = task?["description"]! as? String
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleLabel.text = task?["title"]! as? String
        descriptionLabel.text = task?["description"]! as? String
    }

    @IBAction func onBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditTaskSegue" {
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? NewTaskViewController {
                targetController.task = task
            }
        }
    }
    
    @IBAction func onEditButton(_ sender: Any) {
        performSegue(withIdentifier: "EditTaskSegue", sender: self)
    }
    
}
