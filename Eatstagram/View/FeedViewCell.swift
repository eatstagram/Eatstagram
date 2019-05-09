//
//  FeedViewCell.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/20/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import AlamofireImage
import SDWebImage
import MaterialComponents.MaterialActivityIndicator

protocol FeedDelegate {
    func didPressComment(postID: String)
    func didPressLike(isLiked: Bool, index: Int, numLikes: Int)
    func didPressProfileImageView(index: Int)
}

class FeedViewCell: UITableViewCell {

    //IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numLikesLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    //Variable
    var isLiked: Bool!
    var delegate: FeedDelegate!
    var postID = ""
    var post: Post!
    let activityIndicator = MDCActivityIndicator()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addActionToImageView()
        
        photoImageView.layer.cornerRadius = 15
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.contentMode = .scaleAspectFill
        
        setupIndicator()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //add action to image view
    fileprivate func addActionToImageView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc fileprivate func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.delegate.didPressProfileImageView(index: self.likeButton.tag)
    }
    
    fileprivate func setupIndicator() {
        activityIndicator.indicatorMode = .determinate
        activityIndicator.sizeToFit()
        activityIndicator.radius = 30
        activityIndicator.progress = 1
        activityIndicator.cycleColors = [.purple, .red, .green, .yellow]
        loadingView.addSubview(activityIndicator)
    }
    
    func setupView(index: Int, feedArray: [Post]) {
        
        let date = feedArray[index].createdAt?.dateValue()
        timeLabel.text = date?.durationAgo()
        
        if feedArray[index].isLiked {
            likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "like24"), for: .normal)
        }
        
        locationLabel.text = feedArray[index].location
        if (feedArray[index].numLikes) < 2 {
            numLikesLabel.text = "\(feedArray[index].numLikes) like"
        } else {
            numLikesLabel.text = "\(feedArray[index].numLikes) likes"
        }
        
        if let url = URL(string: feedArray[index].imageUrl) {
//            SDWebImageManager.shared.loadImage(with: url, options: .progressiveLoad, progress: { (_, _, _) in
//                DispatchQueue.main.async {
//                    self.activityIndicator.startAnimating()
//                }
//            }) { (image, _, _, _, _, _) in
//                //self.photoImageView.image = image
//                self.photoImageView.sd_setImage(with: url, placeholderImage: nil, options: .progressiveLoad)
//                self.activityIndicator.stopAnimating()
//            }
            self.activityIndicator.startAnimating()
            self.photoImageView.sd_setImage(with: url, placeholderImage: nil, options: .continueInBackground, completed: { (_, _, _, _) in
                self.activityIndicator.stopAnimating()
            })
        }
        
        usernameLabel.text = feedArray[index].username
        if let profileUrl = URL(string: feedArray[index].userImageUrl ?? "") {
//            SDWebImageManager.shared.loadImage(with: profileUrl, options: .progressiveLoad, progress: nil) { (image, _, _, _, _, _) in
                self.profileImageView.sd_setImage(with: profileUrl, placeholderImage: nil, options: .continueInBackground)
            //}
        }
    }
    
    fileprivate func updateLikesInFirestore(completion:@escaping (_ isLiked: Bool, _ numLikes: Int) -> (), isLiked: Bool) {
        let queryDoc = Firestore.firestore().collection("posts")
        getPostIDFromFirestore { (postID, snapshot) in
            var numLikes = snapshot.documents[0].data()["numLikes"] as? Int
            numLikes = isLiked ? (numLikes ?? 0) - 1 : (numLikes ?? 0) + 1
            if (numLikes ?? 0) < 2 {
                self.numLikesLabel.text = "\(numLikes ?? 0) like"
            } else {
                self.numLikesLabel.text = "\(numLikes ?? 0) likes"
            }
            queryDoc.document(self.postID).updateData(([
                "numLikes": numLikes ?? 0
                ]), completion: { (error) in
                    if let error = error {
                        print("Cannot update likes ", error)
                    }
                    print("Done")
                    completion(isLiked, numLikes ?? 0)
            })
            
            self.updateAndDeleteLikes(isLiked: isLiked, queryDoc: queryDoc)
        }
    }
    
    fileprivate func updateAndDeleteLikes(isLiked: Bool, queryDoc: CollectionReference) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        if !isLiked {
            //update isLiked collection
            queryDoc.document(self.postID).collection("isLiked").document(uid).setData([
                "isLiked": true
                ], completion: { (error) in
                    if let error = error {
                        print("cannot update isLiked collection ", error)
                    }
                    print("Successfully update isLiked collection")
            })
        } else {
            //delete isLiked related to uid
            queryDoc.document(self.postID).collection("isLiked").document(uid).delete(completion: { (error) in
                if let error = error {
                    print("Cannot delete the isLiked ", error)
                } else {
                    print("Successfully delete the isLiked")
                }
            })
        }
    }
    
    fileprivate func getPostIDFromFirestore(completion: @escaping (_ postID: String, _ snapshot: QuerySnapshot)->()) {
        if let createdAt = post.createdAt {
            Firestore.firestore().collection("posts").whereField("createdAt", isEqualTo: createdAt).limit(to: 1).getDocuments { (snapshot, error) in
                self.postID = snapshot?.documents[0].documentID ?? ""
                completion(self.postID, snapshot!)
            }
        }
    }
    
    //IBActions
    @IBAction func likeButtonPressed(_ sender: Any) {
        if !isLiked {
            likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
            updateLikesInFirestore(completion: { (isLiked, numLikes)  in
                self.delegate.didPressLike(isLiked: isLiked, index: self.likeButton.tag, numLikes: numLikes)
            }, isLiked: isLiked)
            isLiked = true
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "like24"), for: .normal)
            updateLikesInFirestore(completion: { (isLiked, numLikes) in
                self.delegate.didPressLike(isLiked: isLiked, index: self.likeButton.tag, numLikes: numLikes)
            }, isLiked: isLiked)
            isLiked = false
        }
    }
    
    @IBAction func commentButtonPressed(_ sender: Any) {
        getPostIDFromFirestore { (postID, snapshot) in
            self.delegate.didPressComment(postID: postID)
        }
    }
}
