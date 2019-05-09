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

let defaults = UserDefaults.standard
let emailKey = "email"

class LoginViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var loginStackView: UIStackView!
    
    //Variables
    fileprivate let loginHUD = JGProgressHUD(style: .dark)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //defaults.set(nil, forKey: emailKey)
        
        setupLayout()
        setupNotificationObservers()
        setupTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createGradientLayer(gradientView: gradientView)
        gradientView.bringSubviewToFront(logoImageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if defaults.string(forKey: emailKey) != nil {
            //print(defaults.string(forKey: emailKey))
            print("It is not nil")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
            self.present(tabBarController, animated:true, completion:nil)
        } else {
            print("It is nil")
        }
    }
    
    func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handletapDismiss)))
    }
    
    @objc fileprivate func handletapDismiss() {
        self.view.endEditing(true)
    }
    
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func handleKeyboardHide() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    @objc fileprivate func handleKeyboardShow(notification: Notification) {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else { return }
        let keyboardFrame = value.cgRectValue
        let bottomSpace = view.frame.height - loginStackView.frame.origin.y - loginStackView.frame.height
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 15)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //put gradient for top view and style the buttons
    fileprivate func setupLayout() {
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        //createGradientLayer(gradientView: gradientView)
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
            
            defaults.set(email, forKey: emailKey)
            self.loginHUD.dismiss()
            print("Successfully log in")
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
            self.present(tabBarController, animated:true, completion:nil)
        }
    }
    
    //Actions
    @IBAction func loginBtnPressed(_ sender: Any) {
        loginHUD.textLabel.text = "Please wait"
        loginHUD.show(in: self.view, animated: true)
        performLogin()
    }
    
    
    
}
