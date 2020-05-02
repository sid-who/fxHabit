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
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    let alertService = AlertService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }
    
    func setUpView() {
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.white.cgColor
        
        // Adding bottom border to text fields
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: usernameTextField.frame.height - 1, width: usernameTextField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.gray.cgColor
        
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: usernameTextField.frame.height - 1, width: usernameTextField.frame.width, height: 1.0)
        bottomLine2.backgroundColor = UIColor.gray.cgColor
        
        usernameTextField.layer.addSublayer(bottomLine)
        passwordTextField.layer.addSublayer(bottomLine2)
    }
    
    @IBAction func onLoginButton(_ sender: Any) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        // automatically checks if username and password is blank. Will print out error if so
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                //Add something here to check if the user has a task limit on their list, if none exists set that limit to 3 by default?
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                let alertVC = self.alertService.alert(error: "Error: " + error!.localizedDescription)
                self.present(alertVC, animated: true, completion: nil)
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    alertVC.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func onSignupButton(_ sender: Any) {
        let user = PFUser();
        
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        user["streakValue"] = 0
        user["lastSaveDate"] = ""
        
        user.signUpInBackground { (success, error) in
            if success {
                self.createEmptyLists()
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                let alertVC = self.alertService.alert(error: "Error: " + error!.localizedDescription)
                self.present(alertVC, animated: true, completion: nil)
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    alertVC.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func createEmptyLists() {
        let friendsList = PFObject(className: "FriendsList")
        friendsList["user"] = PFUser.current()!
        friendsList["friends"] = [String]()
        friendsList.saveInBackground()
        
        let pendingFriends = PFObject(className: "PendingFriends")
        pendingFriends["user"] = PFUser.current()!
        pendingFriends["sentRequest"] = [String]()
        pendingFriends["pendingRequest"] = [String]()
        pendingFriends.saveInBackground()
        
        return
    }
    
    /*
    
    default = 3..
    function = 3 + (streakValue/14) <--- int to truncate
    
    */
}
