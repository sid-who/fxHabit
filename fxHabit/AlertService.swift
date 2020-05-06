//
//  AlertService.swift
//  fxHabit
//
//  Created by Yazmin Carrillo on 5/1/20.
//  Copyright © 2020 gsidhu.ycarrillo.dduong.pwhipp. All rights reserved.
//

import Foundation
import UIKit

class AlertService {
    func alert(error: String) -> AlertViewController {
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        
        alertVC.alertBody = error
        return alertVC
    }
}
