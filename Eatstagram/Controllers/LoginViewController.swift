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
        
        setupLayout()
    }
    
    //put gradient for top view and style the buttons
    fileprivate func setupLayout() {
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        createGradientLayer(gradientView: gradientView)
        gradientView.bringSubviewToFront(logoImageView)
    }
    
    //login user with email and password
    fileprivate func performLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
                showHUDWithError(error: error, text: "Failed login", view: self.view, existHud: self.loginHUD)
                return
            }
            
            self.loginHUD.dismiss()
            print("Successfully log in")
            
            // new View Controller
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let uploadViewController = storyBoard.instantiateViewController(withIdentifier: "uploadViewController") as! NewpostViewController
            //self.present(uploadViewController, animated: true, completion: nil)
            let navController = UINavigationController(rootViewController: uploadViewController)
            self.present(navController, animated:true, completion:nil)
            
        }
    }
    
    //Actions
    @IBAction func loginBtnPressed(_ sender: Any) {
        loginHUD.textLabel.text = "Please wait"
        loginHUD.show(in: self.view, animated: true)
        performLogin()
    }
    
    
    
}
