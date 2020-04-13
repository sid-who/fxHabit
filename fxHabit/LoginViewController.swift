//
//  LoginViewController.swift
//  fxHabit
//
//  Created by Yazmin Carrillo on 4/8/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextBox: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorTextBox.text = ""
    }
    
    @IBAction func onLoginButton(_ sender: Any) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.errorTextBox.text = error!.localizedDescription
            }
        }
    }
    
    @IBAction func onSignupButton(_ sender: Any) {
        let user = PFUser();
        
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        let image = UIImage(named: "profile_tab.png")
        let imageData = image?.pngData()
        let file = PFFileObject(name: "profile.png", data: imageData!)
        user["profilePic"] = file
        
        user.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.errorTextBox.text = error!.localizedDescription
            }
        }
    }
}
