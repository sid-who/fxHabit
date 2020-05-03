//
//  ViewEntryViewController.swift
//  fxHabit
//
//  Created by user163799 on 4/13/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse

class ViewEntryViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var titleViewBlock: UIView!
    @IBOutlet weak var descriptionViewBlock: UIView!
    
    var entry : PFObject?
    var taskColor = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
    }
    
    func setupView() {
        titleViewBlock.layer.cornerRadius = 15
        titleViewBlock.backgroundColor = taskColor[0]
        descriptionViewBlock.layer.cornerRadius = 15
        descriptionViewBlock.backgroundColor = taskColor[1]
        
        titleLabel.text = entry?["title"]! as? String
        bodyTextView.text = entry?["body"]! as? String
        dateLabel.text = entry?["date"]! as? String
    }
    
    @IBAction func onBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEntrySegue" {
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? NewEntryViewController {
                targetController.entry = entry
            }
        }
    }
    
    @IBAction func onEditButton(_ sender: Any) {
        performSegue(withIdentifier: "EditEntrySegue", sender: self)
    }
}
