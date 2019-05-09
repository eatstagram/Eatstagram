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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FeedDelegate {

    //IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noResLabel: UILabel!
    
    //Variable
    var posts = [Post]()
    var searchPosts = [Post]()
    var tempPosts = [Post]()
    let newPostNotificationName = Notification.Name(rawValue: addNewPostNotificationKey)
    fileprivate let loadingHUD = JGProgressHUD(style: .dark)
    let newImageNotificationName = Notification.Name(rawValue: addNewImageNotificationKey)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapGesture()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        if tabBarController?.selectedIndex == 1 {
            searchBar.delegate = self
            tableView.isHidden = true
            noResLabel.isHidden = true
        }
        
        if tabBarController?.selectedIndex == 0 {
            let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Logo-black"))
            logoImageView.contentMode = .scaleAspectFit
            self.navigationItem.titleView = logoImageView
            loadingHUD.textLabel.text = "Loading"
            loadingHUD.show(in: self.view, animated: true)
            fetchPostFromFirestore {}
            createObserver()
        }
    }
    
    func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handletapDismiss)))
    }
    
    @objc fileprivate func handletapDismiss(tapGestureRecognizer: UITapGestureRecognizer) {
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
    
    //listen to notification center
    fileprivate func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: newPostNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: newImageNotificationName, object: nil)
    }
    
    @objc func refreshData() {
        posts.removeAll()
        fetchPostFromFirestore {}
    }
    
    //fetch post
    fileprivate func fetchPostFromFirestore(completion: @escaping () -> ()) {
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
                            if !self.posts.isEmpty {
                                self.tableView.separatorStyle = .singleLine
                            }
                            completion()
                        })
                    })
                }, uid: uid ?? "")
            }
        }
        self.loadingHUD.dismiss(afterDelay: 2)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadingHUD.show(in: self.view, animated: true)
        loadingHUD.textLabel.text = "Searching"
        searchPosts.removeAll()
        posts.removeAll()
        fetchPostFromFirestore {
            self.searchPosts = self.posts.filter({ (post) -> Bool in
                return post.detail?.lowercased().contains(searchBar.text?.lowercased() ?? "") ?? false
            })
            self.view.endEditing(true)
            //self.loadingHUD.dismiss(afterDelay: 2, animated: true)
            //Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
            if self.searchPosts.isEmpty {
                self.tableView.isHidden = true
                self.noResLabel.isHidden = false
            } else {
                self.tableView.isHidden = false
            }
            self.tableView.reloadData()
            self.loadingHUD.dismiss()
           // }
        }
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
        switch tabBarController?.selectedIndex {
        case 0:
            return posts.count
        default:
            return searchPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! FeedViewCell
        if self.tabBarController?.selectedIndex == 0 {
            tempPosts = posts
        } else if self.tabBarController?.selectedIndex == 1 {
            tempPosts = searchPosts
        }
        
        cell.likeButton.tag = indexPath.row
        cell.isLiked = tempPosts[indexPath.row].isLiked
        cell.setupView(index: indexPath.row, feedArray: tempPosts)
        cell.post = tempPosts[indexPath.row]
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
        switch tabBarController?.selectedIndex {
        case 0:
            detailVC.post = posts[indexPath.row]
        default:
            detailVC.post = searchPosts[indexPath.row]
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //protocol
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
    
    func didPressProfileImageView(index: Int) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let userVC = storyBoard.instantiateViewController(withIdentifier: "userViewController") as! UserViewController
        userVC.isCurrentUser = false
        if tabBarController?.selectedIndex == 0 {
            userVC.uid = posts[index].userId
        } else {
            userVC.uid = searchPosts[index].userId
        }
        self.navigationController?.pushViewController(userVC, animated: true)
    }
}
