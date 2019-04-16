//
//  LoginViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/10/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    
    //private
    fileprivate let loginHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        createGradientLayer()
    }
    
    var gradientLayer: CAGradientLayer!
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.gradientView.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.1568627451, green: 0.1960784314, blue: 0.5725490196, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.3725490196, blue: 0.4274509804, alpha: 1).cgColor]
        self.gradientView.layer.addSublayer(gradientLayer)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientView.bringSubviewToFront(logoImageView)
    }
    
    fileprivate func performLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
                self.showHUDWithError(error: error)
                return
            }
            
            self.loginHUD.dismiss()
            print("Successfully log in")
        }
    }
    
    fileprivate func showHUDWithError(error: Error) {
        loginHUD.dismiss()
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed login"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3)
    }
    
    //Actions
    @IBAction func loginBtnPressed(_ sender: Any) {
        loginHUD.textLabel.text = "Please wait"
        loginHUD.show(in: self.view, animated: true)
        performLogin()
    }
    
    
    
}
