//
//  FeedViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/20/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedDelegate {
    
    //IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //Variable
    var posts = [Post]()
    let newPostNotificationName = Notification.Name(rawValue: addNewPostNotificationKey)
    //var didSelectComment: ((UINavigationController) -> ())?
    
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
        //guard let uid = Auth.auth().currentUser?.uid else {return}
        //fetchUserRelatedToPost(completion: { (user) in
            Firestore.firestore().collection("posts").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Failed fetching the data ", error)
                    return
                }
                
                for document in snapshot!.documents {
                    let uid = document.data()["uid"] as? String
                    self.fetchUserRelatedToPost(completion: { (user) in
                        let post = Post(dictionary: document.data(), user: user)
                        self.posts.append(post)
                        self.tableView.reloadData()
                    }, uid: uid ?? "")
                }
            }
        //}, uid: uid)
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
        return 512
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
        commentVC.test = postID
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func didPressLike(isLiked: Bool, index: Int, numLikes: Int) {
        posts[index].isLiked = !isLiked
        posts[index].numLikes = numLikes
    }
}
