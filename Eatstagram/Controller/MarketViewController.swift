//
//  MarketViewController.swift
//  Eatstagram
//
//  Created by hor kimleng on 5/6/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class MarketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //IBOutlets
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
    fileprivate let processingHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchCoinForUser()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "marketCell") as! MarketCell
        cell.setUpView(index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! MarketCell
        addMoneyToUser(price: Int(cell.priceArray[indexPath.row]) ?? 0)
    }
    
    fileprivate func fetchCoinForUser() {
        if let currentUser = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(currentUser).getDocument { (snapshot, error) in
                if let error = error {
                    print("Cannot get the money", error)
                    return
                }
                
                if ((snapshot?.get("coins")) != nil) {
                    let coins = snapshot?.get("coins") as! Int
                    self.coinLabel.text = "\(coins)"
                } else {
                    self.coinLabel.text = "0"
                }
            }
        }
    }
    
    fileprivate func addMoneyToUser(price: Int) {
        processingHUD.show(in: self.view, animated: true)
        processingHUD.textLabel.text = "Processing..."
        if let currentUser = Auth.auth().currentUser?.uid {
            let userDoc = Firestore.firestore().collection("users").document(currentUser)
            userDoc.getDocument { (snapshot, error) in
                if let error = error {
                    print("Cannot check money for user ", error)
                    return
                }
                
                //print("Successfully check money for user")
                
                if ((snapshot?.get("coins")) != nil) {
                    let previousPrice = snapshot?.get("coins") as! Int
                    let currentPrice = previousPrice + price
                    userDoc.updateData(["coins": currentPrice], completion: { (error) in
                        if let error = error {
                            print("Cannot add money for user ", error)
                            return
                        }
                        print("Successfully add money for user")
                        self.processingHUD.textLabel.text = "Validate..."
                        self.processingHUD.dismiss(afterDelay: 3, animated: true)
                        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
                            self.coinLabel.text = "\(currentPrice)"
                        })
                    })
                } else {
                    userDoc.updateData(["coins": price], completion: { (error) in
                        if let error = error {
                            print("Cannot put money for user ", error)
                            return
                        }

                        print("Successfully put money for user")
                        self.processingHUD.textLabel.text = "Validate..."
                        self.processingHUD.dismiss(afterDelay: 3, animated: true)
                        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
                            self.coinLabel.text = "\(price)"
                        })
                    })
                }
            }
        }
    }
}
