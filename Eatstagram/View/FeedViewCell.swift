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

protocol FeedDelegate {
    func didPressComment(postID: String)
    func didPressLike(isLiked: Bool, index: Int, numLikes: Int)
}

class FeedViewCell: UITableViewCell {

    //IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numLikesLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    //Variable
    var isLiked: Bool!
    var delegate: FeedDelegate!
    var postID = ""
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photoImageView.layer.cornerRadius = 15
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(index: Int, feedArray: [Post]) {
        
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
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.photoImageView.image = image
            }
        }
        usernameLabel.text = feedArray[index].username
        if let profileUrl = URL(string: feedArray[index].userImageUrl ?? "") {
            SDWebImageManager.shared.loadImage(with: profileUrl, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.profileImageView.image = image
            }
        }
    }
    
    fileprivate func updateLikesInFirestore(completion:@escaping (_ isLiked: Bool, _ numLikes: Int) -> (), isLiked: Bool) {
        let queryDoc = Firestore.firestore().collection("posts")
        getPostIDFromFirestore { (postID, snapshot) in
            var numLikes = snapshot.documents[0].data()["numLikes"] as? Int
            numLikes = isLiked ? (numLikes ?? 0) - 1 : (numLikes ?? 0) + 1
            queryDoc.document(self.postID).updateData(([
                "numLikes": numLikes ?? 0
                ]), completion: { (error) in
                    if let error = error {
                        print("Cannot update likes ", error)
                    }
                    if (numLikes ?? 0) < 2 {
                        self.numLikesLabel.text = "\(numLikes ?? 0) like"
                    } else {
                        self.numLikesLabel.text = "\(numLikes ?? 0) likes"
                    }
                    print("Done")
                    completion(isLiked, numLikes ?? 0)
            })
        }
//        if let createdAt = post.createdAt {
//            let queryDoc = Firestore.firestore().collection("posts")
//            queryDoc.whereField("createdAt", isEqualTo: createdAt).limit(to: 1).getDocuments { (snapshot, error) in
//                var numLikes = snapshot?.documents[0].data()["numLikes"] as? Int
//                numLikes = isLiked ? (numLikes ?? 0) - 1 : (numLikes ?? 0) + 1
//                self.postID = snapshot?.documents[0].documentID ?? ""
//                queryDoc.document(self.postID).updateData(([
//                    "numLikes": numLikes ?? 0
//                    ]), completion: { (error) in
//                        if let error = error {
//                            print("Cannot update likes ", error)
//                        }
//                        self.numLikesLabel.text = "\(numLikes ?? 0) likes"
//                })
//            }
//        }
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
