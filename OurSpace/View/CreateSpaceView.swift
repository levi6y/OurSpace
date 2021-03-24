//
//  CreateSpaceView.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/3.
//

import SwiftUI
import Firebase
import GoogleSignIn
import Dispatch
import PromiseKit
struct CreateSpaceView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @Binding var createEmail: String
    @Binding var m: String
    @Binding var show:Bool
    //@Binding var spacelist:[Space]
    @Binding var spaceName:String
    //@Binding var userlist:[User]
    func createSpace(){
        let currentUser = Auth.auth().currentUser
        let currentUserEmail = currentUser?.email
        let ref = Database.database().reference().child("spaces")
        guard let uid:String = ref.child("spaces").childByAutoId().key else { return }
        
        let o:NSDictionary = [ "u1" : currentUserEmail!, "u2": createEmail.lowercased(), "name": spaceName, "uid":uid, "numOfPhotos":0,"numOfLogs":0,"numOfAnniversaries":0]
        ref.child(uid).setValue(o)
        /*
        ref.child(uid).child("u1").setValue(currentUserEmail)
        ref.child(uid).child("u2").setValue(createEmail.lowercased())
        ref.child(uid).child("name").setValue(spaceName)
        ref.child(uid).child("uid").setValue(uid)
        ref.child(uid).child("numOfPhotos").setValue(0)
        ref.child(uid).child("numOfLogs").setValue(0)
        ref.child(uid).child("numOfAnniversaries").setValue(0)
 */
        let _ = googleDelegate.trackSpaceListOnce2()
            .done{_ in
                
                withAnimation(.spring()){
                    googleDelegate.isLoading = false
                }
                spaceName = ""
                createEmail = ""
                m = "Space Created!"
                show = true
            }
        return
    }

    func validateForm(){
        var result = false
        withAnimation(.spring()){
            googleDelegate.isLoading = true
        }

        googleDelegate.userL.removeAll()
        googleDelegate.spaceL.removeAll()
        //print("userL: " + String(googleDelegate.userL.count) + " spaceL: " + String(googleDelegate.spaceL.count))
        _ = googleDelegate.trackSpaceListOnce2()
            .then { _ -> Promise<Bool> in
                return googleDelegate.trackUserListOnce2()
            }.done { _ in
                //print("userL: " + String(googleDelegate.userL.count) + " spaceL: " + String(googleDelegate.spaceL.count))
                result = v()
                //print("result: \(result)")
                if (result){
                    createSpace()
                }else{
                    withAnimation(.spring()){
                        googleDelegate.isLoading = false
                    }
                }
            }
        
    }

    func v() -> Bool{
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let currentUserEmail2 = Auth.auth().currentUser!.email
        let currentUserEmail = String(currentUserEmail2!).lowercased()
        let e = createEmail.lowercased()

        if e.isEmpty || spaceName.isEmpty{
            m = "email address and space name are required."
            
            show = true
            return false
        }else if !(emailTest.evaluate(with: e)){
            m = "Invalid Email address."

            show = true
            return false
        }else if currentUserEmail == e{
            m = "Can not create a space with yourself."

            show = true
            return false
        }
        var tempbool = false
        for user in googleDelegate.userL{
            if (user.email == e){
                tempbool = true
                break
            }
        }
        if !tempbool {
            m = "This email address does not exist."

            show = true
            return false
        }
        
        for space in googleDelegate.spaceL{
            if currentUserEmail == space.u1 || currentUserEmail == space.u2{
                if space.name == spaceName{
                    m = "You already have a space with this name."

                    show = true
                    return false
                }else if (currentUserEmail == space.u1 && e == space.u2) || (currentUserEmail == space.u2 && e == space.u1){
                    m = "You can only have one space with this user."

                    show = true
                    return false
                }
            }
        }
        
        return true
    }
    var body: some View {
        VStack{
            
            HStack{
                
                Text("Create A Space")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
                
            }
            .padding()
            .padding(.top,edges!.top)
            .background(Color("c2"))
            .shadow(color: Color.white.opacity(0.06), radius: 5, x: 0, y: 5)
            //Spacer(minLength: 0)
            
            
            //Logo()
            /*
            HStack{
                Button(action: {
                    
                }){
                    Text("Please Enter His/Her Email Address.")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding(.vertical,10)
                        .frame(width: UIScreen.main.bounds.width - 50)
                }.background(Color.white)
                .clipShape(Capsule())
            }.background(Color.black.opacity(0.1))
            .clipShape(Capsule())
            .padding(.top,25)
            
            
            */
            VStack{
                VStack{
                    HStack(spacing: 15){
                        
                        TextField("Enter Space Name", text: $spaceName)
                    }.padding(.vertical,20)
                    Divider()
                    HStack(spacing: 15){
                        Image(systemName: "envelope")
                            .foregroundColor(.black)
                        TextField("Enter His/Her Email Address", text: $createEmail)
                    }.padding(.vertical,20)
                }.padding(.vertical)
                .padding(.horizontal,20)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.bottom,40)
                .shadow(radius: 5)
                
                Button(action:{
                    hideKeyboard()
                    
                    
                    validateForm()
                    
                }){
                    Text("CREATE")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 100)
                }.background(
                    LinearGradient(gradient: .init(colors: [Color("c3"),Color("c2"),Color("c1")]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(8)
                    .offset(y:-70)
                    .shadow(radius: 15)
                    
            }.padding()
            .padding(.top,30)
            Spacer(minLength: 0)
            
            
            
        }
    }
}
