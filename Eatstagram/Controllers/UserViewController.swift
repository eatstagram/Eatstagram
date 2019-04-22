//
//  UserViewController.swift
//  Eatstagram
//
//  Created by Gregory Jueves Mayo on 4/21/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase


class UserViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var urlStrings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchUserImagePost()
        setUpCollectionViewLayout()
        
        // Do any additional setup after loading the view.
    }
    //returning number of elements
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlStrings.count
    }
    //returning the elements inside setting up the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userImagePostCell", for: indexPath) as! UserImagePostCell
        if let url = URL(string: urlStrings[indexPath.item]) {
            cell.imageView.contentMode = .scaleAspectFill
            cell.imageView.sd_setImage(with: url)
        }
        return cell
    }
    
    fileprivate func fetchUserImagePost(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("userImagePosts").document(uid).collection("images").getDocuments { (snapshot, error) in
            for document in snapshot!.documents {
                let urlStrings = document.data()["imageUrl"] as? String
                self.urlStrings.append(urlStrings ?? "")
                self.collectionView.reloadData()
            }
        }
    }

    fileprivate func setUpCollectionViewLayout(){
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let width = (view.frame.width - (2 * layout.minimumInteritemSpacing)) / 3
        layout.itemSize = CGSize(width: width, height: width)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
