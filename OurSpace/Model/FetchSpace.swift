//
//  FetchSpace.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/15.
//



import SwiftUI
import Firebase

func fetchSpace(completion: @escaping ([Space]) -> ()){
    
    var result: [Space] = [Space]()
    print("Fetching Space List")
    var ref: DatabaseReference!
    ref = Database.database().reference().child("spaces")
    
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        let value = snapshot.value as? NSDictionary
        if (value != nil){
            for space in value! {
                
                let temp = space.value as? NSDictionary
                let t1 = temp?["u1"] as? String ?? ""
                let t2 = temp?["u2"] as? String ?? ""
                let t3 = temp?["name"] as? String ?? ""
                let t4 = temp?["uid"] as? String ?? ""
                let t5 = temp?["numOfPhotos"] as? Int ?? -1
                let t6 = temp?["numOfLogs"] as? Int ?? -1
                let t7 = temp?["numOfAnniversaries"] as? Int ?? -1
                let s = Space(u1: t1, u2: t2, name: t3, uid: t4, numOfPhotos: t5, numOfLogs: t6, numOfAnniversaries: t7)
                result.append(s)
                
            }
            
            print(result)
            completion(result)
            
        }else{
            
            
            print("No Space")
            completion(result)
            
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
