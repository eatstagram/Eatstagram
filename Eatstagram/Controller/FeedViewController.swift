//
//  FeedViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/20/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedDelegate {
    
    //IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //Variable
    var posts = [Post]()
    let newPostNotificationName = Notification.Name(rawValue: addNewPostNotificationKey)
    fileprivate let loadingHUD = JGProgressHUD(style: .dark)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Logo-black"))
        logoImageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoImageView
        
        fetchPostFromFirestore()
        createObserver()
    }
    
    //listen to notification center
    fileprivate func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: newPostNotificationName, object: nil)
    }
    
    @objc func refreshData() {
        posts.removeAll()
        fetchPostFromFirestore()
    }
    
    //fetch post
    fileprivate func fetchPostFromFirestore() {
        loadingHUD.textLabel.text = "Loading"
        loadingHUD.show(in: self.view, animated: true)
        tableView.separatorStyle = .none
        Firestore.firestore().collection("posts").order(by: "createdAt", descending: true).getDocuments { (snapshot, error) in
            if let error = error {
                print("Failed fetching the data ", error)
                return
            }

            let currentUid = Auth.auth().currentUser?.uid ?? ""
            
            for document in snapshot!.documents {
                //print(document.documentID)
                let uid = document.data()["uid"] as? String
                self.fetchUserRelatedToPost(completion: { (user) in
                    var post = Post(dictionary: document.data(), user: user)
                    //print(document.documentID)
                    let queryDoc = Firestore.firestore().collection("posts").document(document.documentID).collection("isLiked").document(currentUid)
                    queryDoc.getDocument(completion: { (snapshot, error) in
                        if snapshot!.exists {
                            post.isLiked = true
                        } else {
                            post.isLiked = false
                        }
                        self.posts.append(post)
                        self.posts = self.posts.sorted(by: {$0.createdAt!.compare($1.createdAt!).rawValue > 0})
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                            self.tableView.reloadData()
                            self.loadingHUD.dismiss()
                            self.tableView.separatorStyle = .singleLine
                        })
                    })
                }, uid: uid ?? "")
            }
        }
        self.loadingHUD.dismiss(afterDelay: 2)
    }
    
    //fetch user info related to the post
    fileprivate func fetchUserRelatedToPost(completion: @escaping (_ user: User) -> (), uid: String) {
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Failed fetching the user information ", error)
                return
            }
            
            if let userData = snapshot?.data() {
                let user = User(dictionary: userData)
                completion(user)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! FeedViewCell
        cell.likeButton.tag = indexPath.row
        cell.isLiked = posts[indexPath.row].isLiked
        cell.setupView(index: indexPath.row, feedArray: posts)
        cell.post = posts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 541
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        detailVC.post = posts[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func didPressComment(postID: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let commentVC = storyBoard.instantiateViewController(withIdentifier: "commentViewController") as! CommentViewController
        commentVC.postID = postID
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func didPressLike(isLiked: Bool, index: Int, numLikes: Int) {
        posts[index].isLiked = !isLiked
        posts[index].numLikes = numLikes
    }
}
