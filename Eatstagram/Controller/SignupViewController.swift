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
    @IBOutlet weak var signUpStackView: UIStackView!
    @IBOutlet weak var signUpView: UIView!
    
    //Variables
    fileprivate let signupHUD = JGProgressHUD(style: .dark)
    fileprivate let defaultImageUrl = "https://firebasestorage.googleapis.com/v0/b/eatstagram-c5ab7.appspot.com/o/images%2FdefaultHD.png?alt=media&token=5690af65-3253-485e-a2ea-996c4877f5d5"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupNotificationObservers()
        setupTapGesture()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        let bottomSpace = signUpView.frame.height - signUpStackView.frame.origin.y - signUpStackView.frame.height
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //put gradient for top view and style the buttons
    fileprivate func setupLayout() {
        signupButton.layer.cornerRadius = 5
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        createGradientLayer(gradientView: gradientView)
        gradientView.bringSubviewToFront(logoImageView)
        gradientView.bringSubviewToFront(closeButton)
    }
    
    //register user with email and password
    fileprivate func performRegistration() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
                showHUDWithError(error: error, text: "Failed registration", view: self.view, existHud: self.signupHUD)
                return
            }
            
            self.signupHUD.dismiss()
            self.saveInfoToFirestore()
            //print("Successfully create user ", result?.user.uid)
        }
    }
    
    //after create a new user, users document will add a new document
    fileprivate func saveInfoToFirestore() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] = [
            "username": usernameTextField.text ?? "",
            "image": defaultImageUrl
        ]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
            if let error = error {
                print("Fail to add to the database ", error)
                return
            }
            
            print("Successfully added to the database")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
            self.present(tabBarController, animated:true, completion:nil)
        }
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

