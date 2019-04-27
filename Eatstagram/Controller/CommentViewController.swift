//
//  CommentViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/24/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    //Variables
    var test: String!
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        fetchCommentsFromFirestore()
    }
    
    fileprivate func fetchUserFromFirestore(completion: @escaping (_ username: User)-> (), uid: String) {
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                let user = User(dictionary: data)
                completion(user)
            }
        }
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
            Firestore.firestore().collection("posts").document(self.test).collection("comments").document().setData(commentData, completion: { (error) in
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
        Firestore.firestore().collection("posts").document(test).collection("comments").getDocuments { (snapshots, error) in
            for document in snapshots!.documents {
                let comment = Comment(dictionary: document.data())
                self.comments.append(comment)
                self.tableView.reloadData()
            }
        }
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
    }
    
}
