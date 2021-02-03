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
    @Published var user = User(email: "",  userName: "",uid:"", pic:"")
    
    // Image Picker For Updating Image...
    @Published var picker = false
    @Published var img_data = Data(count: 0)
    
    // Loading View..
    @Published var isLoading = false
    
    
    
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
                print("googleSignedI = false")
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
                print("Successful google sign-in!")
                
                
                let currentUser = Auth.auth().currentUser!
                
                var databasereference: DatabaseReference!
                databasereference = Database.database().reference()
                databasereference.child("users/\(currentUser.uid)/uid").setValue(currentUser.uid)
                databasereference.child("users/\(currentUser.uid)/email").setValue(currentUser.email!)
                fetchUser(uid: currentUser.uid) { (user) in
                    self.user = user
                }
            }
        }
        // If the previous `error` is null, then the sign-in was succesful
        signedIn = true
    }

    
    
}
