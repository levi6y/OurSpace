//
//  GoogleDelegate.swift
//  OurSpace
//
//  Created by Yang Liu on 2020/12/22.
//

import Foundation
import Firebase
import GoogleSignIn

class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
    @Published var signedIn: Bool = false
    @Published var emailVerified: Bool = false
    @Published var user = User(email: "",  userName: "",uid:"", pic:"")
    @Published var spaces = [Space]()
 
    // Image Picker For Updating Image...
    @Published var picker = false
    @Published var img_data = Data(count: 0)
    
    // Loading View..
    @Published var isLoading = false
    @Published var spaceL:[Space] = [Space]()
    @Published var userL:[User] = [User]()
    
    
    func updateImage(){
        
        isLoading = true
        // File located on disk
        
        // Create a reference to the file you want to upload
        let ref = Storage.storage().reference().child("users/" + user.uid + "/userphoto")

        // Upload the file to the path "images/rivers.jpg"
        ref.putData(img_data, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            // Metadata contains file metadata such as size, content-type.
            // You can also access to download URL after upload.
            ref.downloadURL { (url, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                self.isLoading = false
                let currentUser = Auth.auth().currentUser!
                var databasereference: DatabaseReference!
                databasereference = Database.database().reference()
                databasereference.child("users/\(currentUser.uid)/pic").setValue(url!.absoluteString)
                fetchUser(uid: currentUser.uid) { (user) in
                    self.user = user
                }
            }
        }
        
    }
    
    func updateDetails(field : String){
        
        alertView(msg: "") { (txt) in
            
            if txt != ""{
                
                self.updateUsername(id: "userName", value: txt)
            }
        }
        
    }
    
    func updateUsername(id: String,value: String){
        
        let currentUser = Auth.auth().currentUser!
        var databasereference: DatabaseReference!
        databasereference = Database.database().reference()
        
        databasereference.child("users/\(currentUser.uid)/userName").setValue(value)
        fetchUser(uid: currentUser.uid) { (user) in
            self.user = user
        }
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                
                if (Auth.auth().currentUser != nil){
                    let id = Auth.auth().currentUser!.uid
                    fetchUser(uid: id) { (user) in
                        self.user = user
                    }
                    var ref: DatabaseReference!
                    ref = Database.database().reference()
                    ref.child("spaces").observe(DataEventType.value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        if (value != nil){
                            self.spaceL.removeAll()
                            
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
                                self.spaceL.append(s)
                            }
                            print("space list updated")
                            //print(self.spaceL)
                        }else{
                            print("No Space")
                        }
                    })
                    ref.child("users").observe(DataEventType.value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        if (value != nil){
                            self.userL.removeAll()
                            
                            for user in value! {
                                let temp = user.value as? NSDictionary
                                let username = temp?["userName"] as? String ?? "No Username"
                                let uid = temp?["uid"] as? String ?? ""
                                let email = temp?["email"] as? String ?? ""
                                let pic = temp?["pic"] as? String ?? "0"
                                let u = User(email: email, userName: username, uid: uid, pic: pic)
                                self.userL.append(u)
                                
                            }
                            print("user list updated")

                           // print(self.userL)

                        }else{
                            print("No User")
                        }
                    })
                    
                }else{
                    print("No user logged in.")
                }
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        guard let authentication = user.authentication else { return }
          let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                            accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential){ (result, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                
                let currentUser = Auth.auth().currentUser!
                print("Successful google sign-in!")
                var databasereference: DatabaseReference!
                databasereference = Database.database().reference()
                databasereference.child("users/\(currentUser.uid)/uid").setValue(currentUser.uid)
                databasereference.child("users/\(currentUser.uid)/email").setValue(currentUser.email!)
                fetchUser(uid: currentUser.uid) { (user) in
                    self.user = user
                }
                var ref: DatabaseReference!
                ref = Database.database().reference()
                ref.child("spaces").observe(DataEventType.value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if (value != nil){
                        self.spaceL.removeAll()
                        print("updating spaceL")
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
                            self.spaceL.append(s)
                        }
                        //print(self.spaceL)
                    }else{
                        print("No Space")
                    }
                })
                ref.child("users").observe(DataEventType.value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if (value != nil){
                        self.userL.removeAll()
                        print("updating userL")
                        for user in value! {
                            let temp = user.value as? NSDictionary
                            let username = temp?["userName"] as? String ?? "No Username"
                            let uid = temp?["uid"] as? String ?? ""
                            let email = temp?["email"] as? String ?? ""
                            let pic = temp?["pic"] as? String ?? "0"
                            let u = User(email: email, userName: username, uid: uid, pic: pic)
                            self.userL.append(u)
                            
                        }

                       // print(self.userL)

                    }else{
                        print("No User")
                    }
                })
            }
        }
        signedIn = true
    }

    
    
}
