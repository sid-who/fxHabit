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
    
    
    var entry = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = entry[0]["title"]! as? String
        bodyTextView.text = entry[0]["description"]! as? String
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()

        titleLabel.text = entry[0]["title"]! as? String
        bodyTextView.text = entry[0]["description"]! as? String
    }
    
//    override func viewDidAppear() {
//
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    
    @IBAction func onBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
