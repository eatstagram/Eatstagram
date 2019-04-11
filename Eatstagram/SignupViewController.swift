//
//  ViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/10/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class SignupViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    fileprivate let signupHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupButton.layer.cornerRadius = 5
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
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
        gradientView.bringSubviewToFront(closeButton)
    }
    
    fileprivate func performRegistration() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
                self.showHUDWithError(error: error)
                return
            }
            
            self.signupHUD.dismiss()
            //print("Successfully create user ", result?.user.uid)
        }
    }
    
    fileprivate func showHUDWithError(error: Error) {
        signupHUD.dismiss()
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3)
    }
    
    //Actions
    @IBAction func signupBtnPressed(_ sender: Any) {
        signupHUD.textLabel.text = "Please wait"
        signupHUD.show(in: self.view, animated: true)
        performRegistration()
    }
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

