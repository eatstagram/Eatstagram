//
//  CommentViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/24/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentStackView: UIStackView!
    
    //Variables
    var postID: String!
    var comments = [Comment]()
    fileprivate let loadingHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationObservers()
        setupTapGesture()
        tableView.delegate = self
        tableView.dataSource = self
        fetchCommentsFromFirestore()
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
        let bottomSpace = view.frame.height - commentStackView.frame.origin.y - commentStackView.frame.height
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 15)
    }
    
    fileprivate func updateCommentInFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        fetchUserFromFirestore(completion: { (user) in
            let commentData: [String: Any] = [
                "comment": self.commentTextField.text ?? "",
                "createdAt": FieldValue.serverTimestamp(),
                "imageUrl": user.imageUrl ?? "",
                "username": user.username ?? ""
            ]
            Firestore.firestore().collection("posts").document(self.postID).collection("comments").document().setData(commentData, completion: { (error) in
                    if let error = error {
                        print("Cannot add comment into firestore ", error)
                    }
                let comment = Comment(dictionary: commentData)
                self.comments.append(comment)
                self.commentTextField.text = ""
                self.tableView.reloadData()
            })
        }, uid: uid)
    }
    
    fileprivate func fetchCommentsFromFirestore() {
        loadingHUD.textLabel.text = "Loading"
        loadingHUD.show(in: self.view, animated: true)
        Firestore.firestore().collection("posts").document(postID).collection("comments").order(by: "createdAt").getDocuments { (snapshots, error) in
            for document in snapshots!.documents {
                //print(document.documentID)
                let comment = Comment(dictionary: document.data())
                self.comments.append(comment)
                self.tableView.reloadData()
                self.loadingHUD.dismiss()
            }
        }
        self.loadingHUD.dismiss()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
        cell.setUpCell(comment: comments[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    //Actions
    @IBAction func postBtnPressed(_ sender: Any) {
        updateCommentInFirestore()
        self.view.endEditing(true)
    }
    
}
