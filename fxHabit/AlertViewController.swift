//
//  AlertViewController.swift
//  fxHabit
//
//  Created by Yazmin Carrillo on 5/1/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    
    var alertBody = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }
    
    func setUpView() {
        errorLabel.text = alertBody
    }
}
