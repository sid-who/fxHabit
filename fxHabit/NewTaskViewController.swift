//
//  NewTaskViewController.swift
//  fxHabit
//
//  Created by Yazmin Carrillo on 4/8/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse
import SwiftUI

class NewTaskViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.text = ""
        descriptionTextField!.layer.borderWidth = 1
        descriptionTextField!.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func editTitleTextField(_ sender: Any) {
        errorLabel.text = ""
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        if titleTextField.text == "" {
            errorLabel.text = "Missing title."
        } else {
            let task = PFObject(className: "Tasks")
            
            task["author"] = PFUser.current()!
            task["title"] = titleTextField.text
            task["description"] = descriptionTextField.text
            
            task.saveInBackground { (success, error) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.errorLabel.text = error!.localizedDescription
                }
            }
        }
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
