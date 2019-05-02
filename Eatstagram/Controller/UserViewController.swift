//
//  UserViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/21/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class UserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    //IBOulets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    //Variables
    fileprivate let loadingHUD = JGProgressHUD(style: .dark)
    var imagePosts = [ImagePost]()
    let newPostNotificationName = Notification.Name(rawValue: addNewPostNotificationKey)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setUpCollectionViewLayout()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.contentMode = .scaleAspectFill
        
        fetchUserImagePost()
        createObserver()
    }
    
    //listen to notification center
    fileprivate func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: newPostNotificationName, object: nil)
    }
    
    @objc func refreshData() {
        imagePosts.removeAll()
        fetchUserImagePost()
        collectionView.reloadData()
    }
    
    //create alert controller
    fileprivate func createAlertController() {
        let alert = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            do {
                defaults.set(nil, forKey: emailKey)
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Cannot signout")
            }
        }))
        self.present(alert, animated: true)
    }
    
    //fetch images that user posted from firestore
    fileprivate func fetchUserImagePost() {
        loadingHUD.textLabel.text = "Loading"
        loadingHUD.show(in: self.view, animated: true)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        fetchUserFromFirestore(completion: { (user) in
            self.usernameLabel.text = user.username
            self.profileImageView.sd_setImage(with: URL(string: user.imageUrl ?? ""))
            Firestore.firestore().collection("userImagePosts").document(uid).collection("images").order(by: "createdAt", descending: true).getDocuments { (snapshot, error) in
                for document in snapshot!.documents {
                    let imagePost = ImagePost(dictionary: document.data(), username: user.username ?? "")
                    self.imagePosts.append(imagePost)
                    self.collectionView.reloadData()
                    self.loadingHUD.dismiss()
                }
            }
            self.loadingHUD.dismiss()
        }, uid: uid)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userImagePostCell", for: indexPath) as! UserImagePostCell
        if let url = URL(string: imagePosts[indexPath.row].imageURL ?? "") {
            cell.imageView.contentMode = .scaleAspectFill
            cell.imageView.sd_setImage(with: url)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        detailVC.imagePost = imagePosts[indexPath.item]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    fileprivate func setUpCollectionViewLayout() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let width = (view.frame.width - (2 * layout.minimumInteritemSpacing)) / 3
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        createAlertController()
    }
    
}
