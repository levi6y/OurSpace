//
//  FetchUserList.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/15.
//




import SwiftUI
import Firebase

func fetchUserList(completion: @escaping ([User]) -> ()){
    
    var result: [User] = [User]()
    print("Fetching User List")
    var ref: DatabaseReference!
    ref = Database.database().reference().child("users")
    
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        let value = snapshot.value as? NSDictionary
        
        if (value != nil){
            for user in value! {
                print(user.value)
                let temp = user.value as? NSDictionary
                let username = temp?["userName"] as? String ?? "No Username"
                let uid = temp?["uid"] as? String ?? ""
                let email = temp?["email"] as? String ?? ""
                let pic = temp?["pic"] as? String ?? "0"
                
                let u = User(email: email, userName: username, uid: uid, pic: pic)
                result.append(u)
                
            }
            DispatchQueue.main.async {
                print(result)
                completion(result)
            }
        }else{
            
            DispatchQueue.main.async {
                print("No User")
                completion(result)
            }
        }
        
        
        /*
        let u1 = child?["u1"] as? String ?? "No Username"
        let u2 = child?["u2"] as? String ?? ""
        let name = child?["name"] as? String ?? ""
        let uid = child?["uid"] as? String ?? "No Name"
        let numOfPhotos = child?["numOfPhotos"] as? String ?? ""
        let numOfLogs = child?["numOfLogs"] as? String ?? ""
        let numOfAnniversaries = child?["numOfAnniversaries"] as? String ?? ""
        
        
        let username = value?["userName"] as? String ?? "No Username"
        let uid = value?["uid"] as? String ?? ""
        let email = value?["email"] as? String ?? ""
        var pic = value?["pic"] as? String ?? "0"
        
        
         */
        
        }) { (error) in
            print(error.localizedDescription)
    }
    
    
    
    
    
}
