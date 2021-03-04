//
//  GoogleDelegate.swift
//  OurSpace
//
//  Created by Yang Liu on 2020/12/22.
//

import Foundation
import Firebase
import GoogleSignIn
import SwiftUI
import PromiseKit
class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
    @Published var signedIn: Bool = false
    @Published var emailVerified: Bool = false
    @Published var user = User(email: "",  userName: "",uid:"", pic:"")
 
    // Image Picker For Updating Image...
    @Published var picker = false
    @Published var picker2 = false
    @Published var img_data = Data(count: 0)
    @Published var img_data2 = Data(count: 0)
    
    @Published var isLoading = false
    @Published var updatingUserList = false
    @Published var updatingSpaceList = false
    @Published var spaceL:[Space] = [Space]()
    @Published var currentUsersSpaceL:[currentSpace] = [currentSpace]()
    @Published var userL:[User] = [User]()
    @Published var images:[image] = []
    @Published var imagesURL:[String] = []
    @Published var selectedSpace: currentSpace = currentSpace(id: -1,u1: "", u2: "", name: "", uid: "", numOfPhotos: 0, numOfLogs: 0, numOfAnniversaries: 0)

    // for viewing photo's details
    @Published var selectedImages: [String] = []
    @Published var selectedImageID = ""
    @Published var imageViewerOffset: CGSize = .zero
    @Published var bgOpacity: Double = 1
    @Published var showingViewer = false
    @Published var showTabbar = true
    
    @Published var imageScale: CGFloat = 1
    
    func onChange(value: CGSize){
        imageViewerOffset = value
        
        
        //calculating opacity
        
        let h = UIScreen.main.bounds.height / 2
        
        let progress = imageViewerOffset.height / h
        
        withAnimation(.default){
            bgOpacity = Double(1 - (progress < 0 ? -progress : progress))
        }
        
    }
    
    func onEnd(value: DragGesture.Value){
        withAnimation(.easeInOut){
            var t = value.translation.height
            if t<0{
                t = -t
            }
            
            if t<180{
                imageViewerOffset = .zero
                bgOpacity = 1
            }else{
                showingViewer = false
                showTabbar = true
                imageViewerOffset = .zero
                bgOpacity = 1
            }
        }
        
    }
    func updateImage(){
        withAnimation(.spring()){
            isLoading = true
        }
        // File located on disk
        
        // Create a reference to the file you want to upload
        let ref = Storage.storage().reference().child("users/" + user.uid + "/userphoto")

        // Upload the file to the path "images/rivers.jpg"
        ref.putData(img_data, metadata: nil) { (metadata, error) in
            if error != nil {
                withAnimation(.spring()){
                    self.isLoading = false
                }
                print(error!.localizedDescription)
                return
            }
            // Metadata contains file metadata such as size, content-type.
            // You can also access to download URL after upload.
            ref.downloadURL { (url, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    withAnimation(.spring()){
                        self.isLoading = false
                    }
                    return
                }
                
                let currentUser = Auth.auth().currentUser!
                var databasereference: DatabaseReference!
                databasereference = Database.database().reference()
                databasereference.child("users/\(currentUser.uid)/pic").setValue(url!.absoluteString)
                fetchUser(uid: currentUser.uid) { (user) in
                    self.user = user
                }
                withAnimation(.spring()){
                    self.isLoading = false
                }
            }
        }
        
    }
    func uploadPhoto(){
        
        withAnimation(.spring()){
            self.isLoading = true
        }
        // File located on disk
        
        // Create a reference to the file you want to upload
        guard let u:String = Database.database().reference().childByAutoId().key else { return }
        let ref = Storage.storage().reference().child("spaces/" + selectedSpace.uid + "/photo/" + u)
        
        
        // Upload the file to the path "images/rivers.jpg"
        ref.putData(img_data2, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                withAnimation(.spring()){
                    self.isLoading = false
                }
                return
            }
            // Metadata contains file metadata such as size, content-type.
            // You can also access to download URL after upload.
            ref.downloadURL { (url, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    withAnimation(.spring()){
                        self.isLoading = false
                    }
                    return
                }
                
                var databasereference: DatabaseReference!
                databasereference = Database.database().reference()
                self.selectedSpace.numOfPhotos += 1
                databasereference.child("spaces/\(self.selectedSpace.uid)/numOfPhotos").setValue(self.selectedSpace.numOfPhotos)
                
                var ref: DatabaseReference!
                ref = Database.database().reference()
                ref.child("spaces").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    self.currentUsersSpaceL.removeAll()
                    if (value != nil){
                        var i = 0
                        for space in value! {
                            let temp = space.value as? NSDictionary
                            let t1 = temp?["u1"] as? String ?? ""
                            let t2 = temp?["u2"] as? String ?? ""
                            let t3 = temp?["name"] as? String ?? ""
                            let t4 = temp?["uid"] as? String ?? ""
                            let t5 = temp?["numOfPhotos"] as? Int ?? -1
                            let t6 = temp?["numOfLogs"] as? Int ?? -1
                            let t7 = temp?["numOfAnniversaries"] as? Int ?? -1
                            let e = Auth.auth().currentUser?.email
                            if (e != nil && e != ""){
                                if (t1 == e || t2 == e){
                                    let s2 = currentSpace(id:i, u1: t1, u2: t2, name: t3, uid: t4, numOfPhotos: t5, numOfLogs: t6, numOfAnniversaries: t7)
                                    self.currentUsersSpaceL.append(s2)
                                    i += 1
                                }
                            }
                        }
                        for s in self.currentUsersSpaceL{
                            if s.uid == self.selectedSpace.uid{
                                let r = Storage.storage().reference().child("spaces/" + self.selectedSpace.uid + "/photo")
                                

                                r.listAll { (result, error) in
                                    if let error = error {
                                        print(error.localizedDescription)
                                        withAnimation(.spring()){
                                            self.isLoading = false
                                        }
                                        return
                                    }
                                    var i = 0
                                    self.images.removeAll()
                                    self.imagesURL.removeAll()
                                    for item in result.items{
                                        item.downloadURL{ url, error in
                                            if let error = error {
                                                print(error.localizedDescription)
                                                withAnimation(.spring()){
                                                    self.isLoading = false
                                                }
                                                return
                                            } else {
                                                let temp = image(id: i, URL: url!.absoluteString, ref: item)
                                                i += 1
                                                self.images.append(temp)
                                                self.imagesURL.append(url!.absoluteString)
                                                if self.images.count == s.numOfPhotos{
                                                    withAnimation(.spring()){
                                                        self.isLoading = false
                                                    }
                                                    print("images count = \(self.images.count)")
                                                    return
                                                }
                                            }
                                        }
                                    }//end of for item loop
                                }// end of list all
                                print("images count = \(self.images.count)")
                                withAnimation(.spring()){
                                    self.isLoading = false
                                }
                                return
                            }
                        }// end of for loop
                        
                        
                    }

                })
                
                
            }
        }
        
    }
    
    func updateDetails(field : String){
        hideKeyboard()
        alertView(msg: "username") { (txt) in
            
            if txt != ""{
                withAnimation(.spring()){
                    self.isLoading = true
                }
                self.updateUsername(id: "userName", value: txt)
            }
        }
        
    }
    func getPhotosURL(){
        hideKeyboard()
        withAnimation(.spring()){
            self.isLoading = true
        }
        let ref = Storage.storage().reference().child("spaces/" + selectedSpace.uid + "/photo")
        images.removeAll()
        imagesURL.removeAll()

        ref.listAll { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                withAnimation(.spring()){
                    self.isLoading = false
                }
                return
            }
            var i = 0
            for item in result.items{

                item.downloadURL{ url, error in
                    if let error = error {
                        print(error.localizedDescription)
                        withAnimation(.spring()){
                            self.isLoading = false
                        }
                        return
                    } else {
                        let temp = image(id: i, URL: url!.absoluteString, ref: item)
                        i += 1
                        self.images.append(temp)
                        self.imagesURL.append(url!.absoluteString)
                        if self.images.count == self.selectedSpace.numOfPhotos{
                            withAnimation(.spring()){
                                self.isLoading = false
                            }
                            print("images count = \(self.images.count)")
                            return
                        }
                    }
                }
            }
            
        }
        print("images count = \(self.images.count)")
        withAnimation(.spring()){
            self.isLoading = false
        }
        return
    }
    func trackUserAndSpaceList(){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("spaces").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.spaceL.removeAll()
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
                //print("space list updated")
                //print(self.spaceL)
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
                self.userL.removeAll()
                print("user list updated")
            }
        })
    }
    func hideKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func deleteSpace(uid: String){
        
        
        
        alertView(msg: "delete") { (txt) in
            withAnimation(.spring()){
                self.isLoading = true
            }
            if txt == "delete"{
                let ref = Database.database().reference().child("spaces")
                ref.child(uid).removeValue()
                
                self.trackSpaceListOnce()
                
            }
            withAnimation(.spring()){
                self.isLoading = false
            }
        }
        
        
        
        
        
        
    }
    
    func deletePhoto(ref: StorageReference){
        
        alertView(msg: "deletePhoto") { (txt) in
            
            if txt == "delete"{
                withAnimation(.spring()){
                    self.isLoading = true
                }
                
                ref.delete { error in
                    if let error = error {
                        print(error.localizedDescription)
                        withAnimation(.spring()){
                            self.isLoading = false
                        }
                        return
                    } else {
                        var databasereference: DatabaseReference!
                        databasereference = Database.database().reference()
                        self.selectedSpace.numOfPhotos -= 1
                        databasereference.child("spaces/\(self.selectedSpace.uid)/numOfPhotos").setValue(self.selectedSpace.numOfPhotos)
                        
                        var ref: DatabaseReference!
                        ref = Database.database().reference()
                        ref.child("spaces").observeSingleEvent(of: .value, with: { (snapshot) in
                            let value = snapshot.value as? NSDictionary
                            self.currentUsersSpaceL.removeAll()
                            if (value != nil){
                                var i = 0
                                for space in value! {
                                    let temp = space.value as? NSDictionary
                                    let t1 = temp?["u1"] as? String ?? ""
                                    let t2 = temp?["u2"] as? String ?? ""
                                    let t3 = temp?["name"] as? String ?? ""
                                    let t4 = temp?["uid"] as? String ?? ""
                                    let t5 = temp?["numOfPhotos"] as? Int ?? -1
                                    let t6 = temp?["numOfLogs"] as? Int ?? -1
                                    let t7 = temp?["numOfAnniversaries"] as? Int ?? -1
                                    let e = Auth.auth().currentUser?.email
                                    if (e != nil && e != ""){
                                        if (t1 == e || t2 == e){
                                            let s2 = currentSpace(id:i, u1: t1, u2: t2, name: t3, uid: t4, numOfPhotos: t5, numOfLogs: t6, numOfAnniversaries: t7)
                                            self.currentUsersSpaceL.append(s2)
                                            i += 1
                                        }
                                    }
                                }
                                for s in self.currentUsersSpaceL{
                                    if s.uid == self.selectedSpace.uid{
                                        let r = Storage.storage().reference().child("spaces/" + self.selectedSpace.uid + "/photo")
                                        

                                        r.listAll { (result, error) in
                                            if let error = error {
                                                print(error.localizedDescription)
                                                withAnimation(.spring()){
                                                    self.isLoading = false
                                                }
                                                self.images.removeAll()
                                                self.imagesURL.removeAll()
                                                print("images count = \(self.images.count)")
                                                return
                                            }
                                            var i = 0
                                            self.images.removeAll()
                                            self.imagesURL.removeAll()
                                            for item in result.items{
                                                item.downloadURL{ url, error in
                                                    if let error = error {
                                                        print(error.localizedDescription)
                                                        withAnimation(.spring()){
                                                            self.isLoading = false
                                                        }
                                                        return
                                                    } else {
                                                        let temp = image(id: i, URL: url!.absoluteString, ref: item)
                                                        i += 1
                                                        self.images.append(temp)
                                                        self.imagesURL.append(url!.absoluteString)
                                                        if self.images.count == s.numOfPhotos{
                                                            withAnimation(.spring()){
                                                                self.isLoading = false
                                                            }
                                                            print("images count = \(self.images.count)")
                                                            return
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                
                            }

                        })
                    }
                }
            }
            
        }
        
        
    }
    
    
    
    
    
    func trackSpaceListOnce(){
        withAnimation(.spring()){
            updatingSpaceList = true
        }
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("spaces").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.spaceL.removeAll()
            self.currentUsersSpaceL.removeAll()
            if (value != nil){
                var i = 0
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
                    
                    let e = Auth.auth().currentUser?.email
                    if (e != nil && e != ""){
                        if (t1 == e || t2 == e){
                            let s2 = currentSpace(id:i, u1: t1, u2: t2, name: t3, uid: t4, numOfPhotos: t5, numOfLogs: t6, numOfAnniversaries: t7)
                            self.currentUsersSpaceL.append(s2)
                            
                            i += 1
                        }
                    }
                    
                    self.spaceL.append(s)
                }
            }
            self.updatingSpaceList = false
            withAnimation(.spring()){
                self.updatingSpaceList = false
            }
            
        })
        
        
    }
    func trackUserListOnce(){
        withAnimation(.spring()){
            updatingUserList = true
        }
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.userL.removeAll()
            if (value != nil){
                for user in value! {
                    let temp = user.value as? NSDictionary
                    let username = temp?["userName"] as? String ?? "No Username"
                    let uid = temp?["uid"] as? String ?? ""
                    let email = temp?["email"] as? String ?? ""
                    let pic = temp?["pic"] as? String ?? "0"
                    let u = User(email: email, userName: username, uid: uid, pic: pic)
                    self.userL.append(u)
                    
                }
            }
            withAnimation(.spring()){
                self.updatingUserList = false
            }
            
        })
    }
    func trackUserListOnce2() -> Promise<Bool>{
        let p = Promise<Bool> { resolver in
            withAnimation(.spring()){
                updatingUserList = true
            }
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.userL.removeAll()
                if (value != nil){
                    for user in value! {
                        let temp = user.value as? NSDictionary
                        let username = temp?["userName"] as? String ?? "No Username"
                        let uid = temp?["uid"] as? String ?? ""
                        let email = temp?["email"] as? String ?? ""
                        let pic = temp?["pic"] as? String ?? "0"
                        let u = User(email: email, userName: username, uid: uid, pic: pic)
                        self.userL.append(u)
                        
                    }
                }
                withAnimation(.spring()){
                    self.updatingUserList = false
                }
                print("trackUserListOnce2()")
                resolver.fulfill(true)
            })
        }
        return p
    }
    func trackSpaceListOnce2()-> Promise<Bool>{
        let p = Promise<Bool> { resolver in
            withAnimation(.spring()){
                updatingSpaceList = true
            }
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("spaces").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.spaceL.removeAll()
                self.currentUsersSpaceL.removeAll()
                if (value != nil){
                    var i = 0
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
                        
                        let e = Auth.auth().currentUser?.email
                        if (e != nil && e != ""){
                            if (t1 == e || t2 == e){
                                let s2 = currentSpace(id:i, u1: t1, u2: t2, name: t3, uid: t4, numOfPhotos: t5, numOfLogs: t6, numOfAnniversaries: t7)
                                self.currentUsersSpaceL.append(s2)
                                
                                i += 1
                            }
                        }
                        
                        self.spaceL.append(s)
                    }
                }
                withAnimation(.spring()){
                    self.updatingSpaceList = false
                }
                resolver.fulfill(true)
                print("trackSpaceListOnce2()")
            })
        }
        return p
        
        
        
    }
    func updateUsername(id: String,value: String){
        
        let currentUser = Auth.auth().currentUser!
        var databasereference: DatabaseReference!
        databasereference = Database.database().reference()
        
        databasereference.child("users/\(currentUser.uid)/userName").setValue(value)
        fetchUser(uid: currentUser.uid) { (user) in
            self.user = user
            withAnimation(.spring()){
                self.isLoading = false
            }
        }
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        hideKeyboard()
        withAnimation(.spring()){
            self.isLoading = true
        }
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                
                if (Auth.auth().currentUser != nil){
                    let id = Auth.auth().currentUser!.uid
                    fetchUser(uid: id) { (user) in
                        self.user = user
                    }
                    
                    _ = trackSpaceListOnce2()
                        .done{_ in
                            withAnimation(.spring()){
                                self.isLoading = false
                            }
                            
                        }
                }else{
                    withAnimation(.spring()){
                        self.isLoading = false
                    }
                    print("No user logged in.")
                }
            } else {
                withAnimation(.spring()){
                    self.isLoading = false
                }
                print("\(error.localizedDescription)")
            }
            return
        }
        guard let authentication = user.authentication else {
            withAnimation(.spring()){
                self.isLoading = false
            }
            return
            
        }
          let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                            accessToken: authentication.accessToken)
        hideKeyboard()
        Auth.auth().signIn(with: credential){ (result, error) in
            if error != nil {
                withAnimation(.spring()){
                    self.isLoading = false
                }
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
                    //self.trackUserListOnce()
                    self.signedIn = true
                    _ = self.trackSpaceListOnce2()
                        .done{_ in
                            withAnimation(.spring()){
                                self.isLoading = false
                            }
                            
                        }
                }
                
            }
        }
        
    }

    
    
}
