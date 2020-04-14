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

class NewEntryViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    var entry : PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()

        // Do any additional setup after loading the view.
        errorLabel.text = ""
        
        // textView setup
        bodyTextView.delegate = self
        bodyTextView!.layer.borderWidth = 1
        bodyTextView!.layer.borderColor = UIColor.lightGray.cgColor
        bodyTextView!.text = "What's on your mind?"
        bodyTextView!.textColor = UIColor.lightGray
        
        if entry != nil {
            
            titleTextField.text = entry!["title"] as? String
            titleTextField.text = entry!["body"] as? String
        }
    }
    
    func dateToString(date:Date) -> String {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd/YY"
        
        return dateFormatterPrint.string(from: date)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.textColor == UIColor.lightGray {

            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    
    @IBAction func onSubmitButton(_ sender: Any) {
        
        if titleTextField.text == "" {
            
            errorLabel.text = "Missing title."
            
        } else if entry != nil {
            entry!["title"] = titleTextField.text
            entry!["body"] = bodyTextView.text
            
            // why no date and author here? I don't understand -pw
            
            entry!.saveInBackground { (success, error) in
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
            entry["date"] = dateToString(date: Date.init())
            
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
        self.dismiss(animated: true, completion: nil)
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
