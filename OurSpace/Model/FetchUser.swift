//
//  FetchUser.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/3.
//

import SwiftUI
import Firebase

func fetchUser(uid: String,completion: @escaping (User) -> ()){
    
    if (uid == ""){
        return
    }
    print("Fetching User: " + uid)
    var ref: DatabaseReference!
    ref = Database.database().reference()
    
    
    ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
      // Get user value
        let value = snapshot.value as? NSDictionary
        
        let username = value?["userName"] as? String ?? "No Username"
        let uid = value?["uid"] as? String ?? ""
        let email = value?["email"] as? String ?? ""
        var pic = value?["pic"] as? String ?? "0"
        
        if (pic == "0" || pic == ""){
            DispatchQueue.main.async {
                print("email: " + email)
                print("userName: " + username)
                print("uid: " + uid)
                print("pic: 0")
                completion(User(email: email, userName: username, uid: uid, pic: "0"))
            }
        }else{
            let ref = Storage.storage().reference().child("users/" + uid + "/userphoto")
            // Fetch the download URL
            ref.downloadURL { url, error in
              if let error = error {
                print(error.localizedDescription)
              } else {
                pic = url!.absoluteString
                
                DispatchQueue.main.async {
                    
                    completion(User(email: email, userName: username, uid: uid, pic: pic))
                }
              }
            }
        }
        
        
        
        
        }) { (error) in
            print(error.localizedDescription)
    }
    
    
    
    
    
}
