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


extension Date {
    init(_ dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        //dateStringFormatter.timeZone = TimeZone(abbreviation: "GMT-4") //Ottawa time zone
        let date = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:date)
    }
}
class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
    @Published var signedIn: Bool = false
    @Published var user = User(email: "",  userName: "",uid:"", pic:"")     // current user
 
    // Image Picker For Updating Image...
    @Published var picker = false
    @Published var picker2 = false
    @Published var img_data = Data(count: 0)
    @Published var img_data2 = Data(count: 0)
    
    @Published var isLoading = false
    @Published var updatingUserList = false
    @Published var updatingSpaceList = false
    @Published var spaceL:[Space] = [Space]()                               // list of all spaces
    @Published var currentUsersSpaceL:[currentSpace] = [currentSpace]()     //spaces that belong to current user
    @Published var userL:[User] = [User]()                                  //list of all users
    @Published var images:[image] = []                                      //for photo function
    @Published var imagesURL:[String] = []                                  //for photo function
    @Published var selectedSpace: currentSpace = currentSpace(id: -1,u1: "", u2: "", name: "", uid: "", numOfPhotos: 0, numOfLogs: 0, numOfAnniversaries: 0)                                              //pressed space

    // for viewing photo's details
    @Published var selectedImages: [String] = []                            //for photo browser
    @Published var selectedImageID = ""                                     //for photo browser
    @Published var imageViewerOffset: CGSize = .zero                        //for photo browser
    @Published var bgOpacity: Double = 1                                    //for photo browser
    @Published var showingViewer = false                                    //for photo browser
    @Published var imageScale: CGFloat = 1                                  //for photo browser
    
    @Published var showTabbar = true
    
    @Published var selectedLog = mylog(id: "", title: "", content: "", spaceuid: "")
    
    @Published var logs:[mylog] = []
    @Published var anniversaries:[mydate] = []

    
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
    func createLog(title:String, content:String) -> Promise<Bool>{
        hideKeyboard()
        
        let p = Promise<Bool> { resolver in
            
            if (title == "" || content == ""){
                
                alertView(msg: "Title/Content is required") { (txt) in
                    
                    if txt != ""{
                        withAnimation(.spring()){
                            self.isLoading = false
                            resolver.fulfill(false)
                        }
                        
                    }
                }
            }else{
                withAnimation(.spring()){
                    self.isLoading = true
                }
                let ref = Database.database().reference().child("logs")
                guard let uid:String = ref.child("spaces").childByAutoId().key else { return }
                let l:NSDictionary = [ "id" : uid, "title": title, "content": content, "spaceuid": self.selectedSpace.uid]
                ref.child(self.selectedSpace.uid).child(uid).setValue(l)
                self.selectedSpace.numOfLogs += 1
                var databasereference: DatabaseReference!
                databasereference = Database.database().reference()
                databasereference.child("spaces/\(self.selectedSpace.uid)/numOfLogs").setValue(self.selectedSpace.numOfLogs)
                withAnimation(.spring()){
                    self.isLoading = false
                }
                resolver.fulfill(true)
            }
            
        }
        return p
        
        
    }
    func createAnniversary(anniversaryDescription: String, anniversaryDate:Date) -> Promise<Bool>{
        hideKeyboard()
        
        let p = Promise<Bool> { resolver in
            
            if (anniversaryDescription == ""){
                
                alertView(msg: "Description is required") { (txt) in
                    
                    if txt != ""{
                        withAnimation(.spring()){
                            self.isLoading = false
                            resolver.fulfill(false)
                        }
                        
                    }
                }
            }else{
                withAnimation(.spring()){
                    self.isLoading = true
                }
                let ref = Database.database().reference().child("anniversaries")
                guard let uid:String = ref.child("spaces").childByAutoId().key else { return }
                let t = String(anniversaryDate.description.prefix(10))
                let y = Int(t.split(separator: "-")[0])!
                let m = Int(t.split(separator: "-")[1])!
                let d = Int(t.split(separator: "-")[2])!
                //print("test: \(y)-\(m)-\(d)    \(anniversaryDate.description)")
                let l:NSDictionary = [ "id" : uid, "description": anniversaryDescription, "year": y, "month": m, "day": d, "spaceuid": self.selectedSpace.uid]
                ref.child(self.selectedSpace.uid).child(uid).setValue(l)
                self.selectedSpace.numOfAnniversaries += 1
                var databasereference: DatabaseReference!
                databasereference = Database.database().reference()
                databasereference.child("spaces/\(self.selectedSpace.uid)/numOfAnniversaries").setValue(self.selectedSpace.numOfAnniversaries)
                resolver.fulfill(true)
                withAnimation(.spring()){
                    self.isLoading = false
                }
                
            }
            
        }
        return p
        
        
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
    
    func getLogs(){
        hideKeyboard()
        withAnimation(.spring()){
            self.isLoading = true
        }
        let ref = Database.database().reference().child("logs/" + selectedSpace.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.logs.removeAll()
            if (value != nil){
                
                for log in value! {
                    let temp = log.value as? NSDictionary
                    let t1 = temp?["id"] as? String ?? ""
                    let t2 = temp?["title"] as? String ?? ""
                    let t3 = temp?["content"] as? String ?? ""
                    let t4 = temp?["spaceuid"] as? String ?? ""
                    let l = mylog(id: t1, title: t2, content: t3, spaceuid: t4)
                    self.logs.append(l)
                }
            }
            withAnimation(.spring()){
                self.isLoading = false
            }
            
        })
    }
    func getAnniversaries(){
        hideKeyboard()
        withAnimation(.spring()){
            self.isLoading = true
        }
        let ref = Database.database().reference().child("anniversaries/" + selectedSpace.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.anniversaries.removeAll()
            if (value != nil){
                
                for anniversary in value! {
                    let temp = anniversary.value as? NSDictionary
                    let t1 = temp?["id"] as? String ?? ""
                    let t2 = temp?["description"] as? String ?? ""
                    let t3 = temp?["year"] as? Int ?? 0
                    let t4 = temp?["month"] as? Int ?? 0
                    let t5 = temp?["day"] as? Int ?? 0
                    let t6 = temp?["spaceuid"] as? String ?? ""
                    let t7 = (t3 * 365) + (t4 * 30) + t5
                    let t8 = String("\(String(t3))-\(t4)-\(t5)")
                    let a = mydate(id: t1, description: t2, year: t3, month: t4, day: t5, spaceuid: t6, value: t7,text: t8)
                    
                    
                    self.anniversaries.append(a)
                }
                self.anniversaries.sort{(d1,d2) -> Bool in
                    return d1.value > d2.value
                }
            }
            withAnimation(.spring()){
                self.isLoading = false
            }
            
        })
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
                
                
                let ref2 = Storage.storage().reference().child("spaces/" + uid + "/photo")
                
                ref2.listAll { (result, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        withAnimation(.spring()){
                            self.isLoading = false
                        }
                        return
                    }
                    
                    if result.items.count == 0{
                        let ref = Database.database().reference()
                        ref.child("logs").child(uid).removeValue()
                        ref.child("anniversaries").child(uid).removeValue()
                        ref.child("spaces").child(uid).removeValue()
                        let _ = self.trackSpaceListOnce2()
                            .done{_ in
                                
                                withAnimation(.spring()){
                                    self.isLoading = false
                                }
                                
                            }
                        
                    }else{
                        var i = 0
                        let flag = result.items.count
                        for item in result.items{
                            item.delete { error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    withAnimation(.spring()){
                                        self.isLoading = false
                                    }
                                    return
                                } else {
                                    i += 1
                                    
                                    if i == flag{
                                        let ref = Database.database().reference()
                                        ref.child("logs").child(uid).removeValue()
                                        ref.child("anniversaries").child(uid).removeValue()
                                        ref.child("spaces").child(uid).removeValue()
                                        let _ = self.trackSpaceListOnce2()
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
                    
                    
                }
                
                
               
                
            }else{
                withAnimation(.spring()){
                    self.isLoading = false
                }
            }
            
        }
        
        
        
        
        
        
    }
    func deleteLog(uid: String){
        
        
        
        alertView(msg: "deletelog") { (txt) in
            
            if txt == "delete"{
                withAnimation(.spring()){
                    self.isLoading = true
                }
                let ref = Database.database().reference().child("logs/" + self.selectedSpace.uid)
                _ = self.removevalue2(ref: ref.child(uid))
                    .done{ _ in
                        self.getLogs()
                        self.selectedSpace.numOfLogs -= 1
                        Database.database().reference().child("spaces/" + self.selectedSpace.uid).child("numOfLogs").setValue(self.selectedSpace.numOfLogs)
                        
                    }
            }
        }
        
    }
    func deleteAnniversary(uid: String){
        
        
        
        alertView(msg: "deleteAnniversary") { (txt) in
            
            if txt == "delete"{
                withAnimation(.spring()){
                    self.isLoading = true
                }
                let ref = Database.database().reference().child("anniversaries/" + self.selectedSpace.uid)
                _ = self.removevalue2(ref: ref.child(uid))
                    .done{ _ in
                        
                        self.selectedSpace.numOfAnniversaries -= 1
                        Database.database().reference().child("spaces/" + self.selectedSpace.uid).child("numOfAnniversaries").setValue(self.selectedSpace.numOfAnniversaries)
                        self.getAnniversaries()
                        
                    }
            }
        }
        
    }
    
    
    func removevalue2(ref: DatabaseReference) -> Promise<Bool>{
        
        let p = Promise<Bool> { resolver in
            withAnimation(.spring()){
                isLoading = true
            }
            ref.removeValue()
            resolver.fulfill(true)
        }
        return p
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
                                                //print("images count = \(self.images.count)")
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
                                                            //print("images count = \(self.images.count)")
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
