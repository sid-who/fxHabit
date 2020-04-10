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

extension UIViewController{
    func HideKeyboard() {
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
}

class NewTaskViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    var task = [PFObject]() 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()

        // Do any additional setup after loading the view.
        errorLabel.text = ""
        descriptionTextField!.layer.borderWidth = 1
        descriptionTextField!.layer.borderColor = UIColor.lightGray.cgColor
        
        if task.count != 0 {
            print(task[0])
            titleTextField.text = task[0]["title"] as? String
            descriptionTextField.text = task[0]["description"] as? String
        }
    }
    
    @IBAction func editTitleTextField(_ sender: Any) {
        errorLabel.text = ""
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        if titleTextField.text == "" {
            errorLabel.text = "Missing title."
        } else if task.count != 0 {
            let query = PFQuery(className:"Tasks")
            query.getObjectInBackground(withId: "xWMyZEGZ") { (gameScore: PFObject?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let gameScore = gameScore {
                    gameScore["cheatMode"] = true
                    gameScore["score"] = 1338
                    gameScore.saveInBackground()
                }
            }
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
