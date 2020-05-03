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
    @IBOutlet weak var titleViewBlock: UIView!
    @IBOutlet weak var descriptionViewBlock: UIView!
    
    var entry : PFObject?
    let alertService = AlertService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()

        setupView()
    }
    
    func setupView() {
        bodyTextView.delegate = self
        bodyTextView.layer.cornerRadius = 3
        
        titleViewBlock.layer.cornerRadius = 15
        descriptionViewBlock.layer.cornerRadius = 15
        
        if entry != nil {
            titleTextField.text = entry?["title"]! as? String
            bodyTextView.text = entry?["body"]! as? String
        } else {
            bodyTextView!.text = "What's on your mind?"
            bodyTextView!.textColor = UIColor.lightGray
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
    
    @IBAction func onTitleEdit(_ sender: Any) {
        titleTextField.placeholder = nil 
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        if titleTextField.text == "" {
            let alertVC = self.alertService.alert(error: "Error: missing title")
            self.present(alertVC, animated: true, completion: nil)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                alertVC.dismiss(animated: true, completion: nil)
            }
        } else if titleTextField.text == "Journal Title" {
            let alertVC = self.alertService.alert(error: "Error: missing title")
            self.present(alertVC, animated: true, completion: nil)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                alertVC.dismiss(animated: true, completion: nil)
            }
        } else if entry != nil {
            entry?["title"] = titleTextField.text
            entry?["body"] = bodyTextView.text
            entry?["date"] = dateToString(date: Date.init())
            
            entry?.saveInBackground { (success, error) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Error in NewEntryVC: " + error!.localizedDescription)
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
                    print("Error in NewEntryVC: " + error!.localizedDescription)
                }
            }
        }
    }
}
