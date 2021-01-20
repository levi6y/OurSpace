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
                databasereference.child("users/\(currentUser.uid)/userName").setValue(currentUser.email!)
            }
        }
        // If the previous `error` is null, then the sign-in was succesful
        signedIn = true
    }

    
    
}
