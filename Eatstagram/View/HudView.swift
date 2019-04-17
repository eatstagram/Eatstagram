//
//  hudView.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/17/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import JGProgressHUD

func showHUDWithError(error: Error, text: String, view: UIView, existHud: JGProgressHUD) {
    existHud.dismiss()
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = text
    hud.detailTextLabel.text = error.localizedDescription
    hud.show(in: view)
    hud.dismiss(afterDelay: 3)
}
