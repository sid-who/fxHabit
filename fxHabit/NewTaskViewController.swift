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
    @IBOutlet weak var titleViewBox: UIView!
    @IBOutlet weak var descriptionViewBox: UIView!
    
    var task : PFObject?
    let alertService = AlertService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()

        setupView()
    }
    
    //
    // Set up design 
    //
    func setupView() {
        descriptionTextField!.layer.cornerRadius = 3
        
        titleViewBox.layer.cornerRadius = 15
        descriptionViewBox.layer.cornerRadius = 15
        
        if task != nil {
            titleTextField.text = task?["title"]! as? String
            descriptionTextField.text = task?["description"]! as? String
        }
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        if titleTextField.text == "" {
            let alertVC = self.alertService.alert(error: "Error: missing title")
            self.present(alertVC, animated: true, completion: nil)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                alertVC.dismiss(animated: true, completion: nil)
            }
        } else if titleTextField.text == "Task Title" {
            let alertVC = self.alertService.alert(error: "Error: missing title")
            self.present(alertVC, animated: true, completion: nil)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                alertVC.dismiss(animated: true, completion: nil)
            }
        } else if task != nil {
            task?["title"] = titleTextField.text
            task?["description"] = descriptionTextField.text
            
            task?.saveInBackground { (success, error) in
                if success {
                    self.performSegue(withIdentifier: "goBackToTaskList", sender: nil)
                } else {
                    print("Error in NewTaskVC: " + error!.localizedDescription)
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
                    print("Error in NewTaskVC: " + error!.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
