//
//  NewEntryViewController.swift
//  fxHabit
//
//  Created by user163799 on 4/13/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse
import SwiftUI

class NewEntryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    var entry = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()

        // Do any additional setup after loading the view.
        errorLabel.text = ""
        bodyTextView!.layer.borderWidth = 1
        bodyTextView!.layer.borderColor = UIColor.lightGray.cgColor
        
        if entry.count != 0 {
            
            titleTextField.text = entry[0]["title"] as? String
            titleTextField.text = entry[0]["body"] as? String
        }
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        
        if titleTextField.text == "" {
            
            errorLabel.text = "Missing title."
            
        } else if entry.count != 0 {
            entry[0]["title"] = titleTextField.text
            entry[0]["body"] = bodyTextView.text
            
            // why no date and author here? I don't understand -pw
            
            entry[0].saveInBackground { (success, error) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.errorLabel.text = "Save failed." // error!.localizedDescription
                }
            }
        } else {
            let entry = PFObject(className: "Entries")
            
            entry["author"] = PFUser.current()!
            entry["title"] = titleTextField.text
            entry["body"] = bodyTextView.text
            entry["date"] = Date.init().description
            
            entry.saveInBackground { (success, error) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.errorLabel.text = error!.localizedDescription
                }
            }
        }
    }
    
    
    @IBAction func onCancelButton(_ sender: Any) {
    }
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
