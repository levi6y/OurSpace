//
//  SettingsView.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/3.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import GoogleSignIn

struct SettingsView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @Binding var logedin: Bool
    @Binding var index: Int
    @Binding var loginemail: String
    @Binding var loginpassword: String
    @Binding var passwordVisible: Bool
    @Binding var signupemail: String
    @Binding var signuppassword: String
    @Binding var signuprepassword: String
    @Binding var signuppasswordVisible: Bool
    @Binding var signuprepasswordVisible: Bool
    @Binding var forgetemail: String
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    
    //@StateObject var settingsData = SettingsViewModel()
    var body: some View {
        
        VStack{
            
            HStack{
                
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
                
            }
            .padding()
            .padding(.top,edges!.top)
            // Top Shadow Effect...
            .background(Color("c2"))
            .shadow(color: Color.white.opacity(0.06), radius: 5, x: 0, y: 5)
            Spacer(minLength: 0)
            if googleDelegate.user.pic != ""  {
                
                ZStack{
                    
                    WebImage(url: URL(string: googleDelegate.user.pic)!)
                        .onSuccess { image, data, cacheType in
                            print("photo success!")
                        }
                        .placeholder{Image("userphoto")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                        } // Placeholder Image
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150,alignment: .center)
                        .clipShape(Circle())
                        
                    
                    if googleDelegate.isLoading{
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("c2")))
                    }
                }
                .padding(.top,25)
                .onTapGesture {
                    googleDelegate.picker.toggle()
                }
            }else{
                
                ZStack{
                    
                    Image("userphoto")
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150,alignment: .center)
                        .clipShape(Circle())
                }
                .padding(.top,25)
            }
            
            HStack(spacing: 15){
                
                if googleDelegate.user.userName != "" {
                    Text(googleDelegate.user.userName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Button(action: {googleDelegate.updateDetails(field: "Name")}) {
                        
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }else{
                    Text("Loading...")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
        
            }
            .padding()

            // LogOut Button...
            Spacer(minLength: 0)
            Spacer(minLength: 0)
            Spacer(minLength: 0)
            signOutButton(logedin: $logedin,index:$index,loginemail:$loginemail, loginpassword: $loginpassword, passwordVisible: $passwordVisible,signupemail:$signupemail,signuppassword:$signuppassword,signuprepassword:$signuprepassword,signuppasswordVisible: $signuppasswordVisible,signuprepasswordVisible: $signuprepasswordVisible,forgetemail: $forgetemail)
                .padding(.bottom,edges!.bottom == 0 ? 55 : 0)
            Spacer(minLength: 0)
            Spacer(minLength: 0)
            
            
        }
        .sheet(isPresented: $googleDelegate.picker) {
         
            ImagePicker(picker: $googleDelegate.picker, img_Data: $googleDelegate.img_data)
        }
        .onChange(of: googleDelegate.img_data) { (newData) in
            // whenever image is selected update image in Firebase...
            googleDelegate.updateImage()
        }
    }
    
    
    struct signOutButton: View {
        @EnvironmentObject var googleDelegate: GoogleDelegate
        @Binding var logedin: Bool
        @Binding var index: Int
        @Binding var loginemail: String
        @Binding var loginpassword: String
        @Binding var passwordVisible: Bool
        @Binding var signupemail: String
        @Binding var signuppassword: String
        @Binding var signuprepassword: String
        @Binding var signuppasswordVisible: Bool
        @Binding var signuprepasswordVisible: Bool
        @Binding var forgetemail: String
        var body: some View {
            Button(action: {
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                  print ("Error signing out: %@", signOutError)
                    logedin = false
                    UserDefaults.standard.set(logedin,forKey: "logedin")
                }
                GIDSignIn.sharedInstance().signOut()
                googleDelegate.signedIn = false
                logedin = false
                UserDefaults.standard.set(logedin,forKey: "logedin")
                index = 0
                loginemail = ""
                loginpassword = ""
                passwordVisible = false
                signupemail = ""
                signuppassword = ""
                signuprepassword = ""
                signuppasswordVisible = false
                signuprepasswordVisible = false
                forgetemail = ""
            }){
                Text("Sign Out")
                    .foregroundColor(Color("c2"))
                    .fontWeight(.bold)
                    .padding(.vertical,10)
                    .frame(width: (UIScreen.main.bounds.width - 50) / 2)
            }.background(Color.white)
            .clipShape(Capsule())
        }
    }
}

