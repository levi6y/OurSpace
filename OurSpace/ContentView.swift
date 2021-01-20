//
//  ContentView.swift
//  OurSpace
//
//  Created by Yang Liu on 2020/12/20.
//

import SwiftUI
import Firebase
import GoogleSignIn
let lightGreyColor = Color(red:239.0/255.0,green: 243.0/255.0, blue:244.0/255.0)

struct ContentView: View {
    @State var index = 0
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @State var loginpasswordVisible: Bool = false
    @State var signuppasswordVisible: Bool = false
    @State var signuprepasswordVisible: Bool = false
    @State var loginemail: String = ""
    @State var loginpassword: String = ""
    @State var signupemail: String = ""
    @State var signuppassword: String = ""
    @State var signuprepassword: String = ""
    var body: some View {
        Group{
            ZStack{
                LinearGradient(gradient: .init(colors: [Color("c1"),Color("c2"),Color("c3")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                if googleDelegate.signedIn{
                    signOutButton()
                }else{
                    
                    VStack{
                        Spacer()
                        Logo()
                        HStack{
                            existingUserButton(index: $index)
                            newUserButton(index: $index)
                        }.background(Color.black.opacity(0.1))
                        .clipShape(Capsule())
                        .padding(.top,25)
                        
                        if self.index == 0{
                            Login(loginemail:$loginemail, loginpassword: $loginpassword, passwordVisible: $loginpasswordVisible)
                        }else{
                            SignUp(signupemail:$signupemail,signuppassword:$signuppassword,signuprepassword:$signuprepassword,signuppasswordVisible: $signuppasswordVisible,signuprepasswordVisible: $signuprepasswordVisible )
                        }
                        
                        if self.index == 0{
                            forgetPasswordButton()
                        }
                        
                        orDivider()
                        
                        GoogleSignInButton()
                        
                        Spacer()
                    }.padding()
                    
                }
            }
        }.onAppear{GIDSignIn.sharedInstance().restorePreviousSignIn()} // uncomment to run on real device.
        
        
        
    }
    
}
struct GoogleSignInButton: UIViewRepresentable {
    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        // Customize button here
        button.colorScheme = .light
        return button
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct Login : View {
    @Binding var loginemail: String
    @Binding var loginpassword: String
    @Binding var passwordVisible: Bool

    @EnvironmentObject var googleDelegate: GoogleDelegate
    var body : some View{
        VStack{
            VStack{
                HStack(spacing: 15){
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    TextField("Enter Email Address", text: self.$loginemail)
                }.padding(.vertical,20)
                Divider()
                passwordField(password: self.$loginpassword,passwordVisible: self.$passwordVisible)
            }.padding(.vertical)
            .padding(.horizontal,20)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.top,25)
            .padding(.bottom,40)
            
            Button(action:{}){
                Text("LOGIN")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 100)
            }.background(
                LinearGradient(gradient: .init(colors: [Color("c3"),Color("c2"),Color("c1")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(8)
                .offset(y:-70)
                .shadow(radius: 15)
                
        }
        
    }
}

struct SignUp : View {
    @Binding var signupemail: String
    @Binding var signuppassword: String
    @Binding var signuprepassword: String
    @Binding var signuppasswordVisible: Bool
    @Binding var signuprepasswordVisible: Bool
    var body : some View{
        VStack{
            VStack{
                HStack(spacing: 15){
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    TextField("Enter Email Address", text: self.$signupemail)
                }.padding(.vertical,20)
                Divider()
                passwordField(password: self.$signuppassword,passwordVisible: self.$signuppasswordVisible)
                Divider()
                passwordField(password: self.$signuprepassword,passwordVisible: self.$signuprepasswordVisible)
            }.padding(.vertical)
            .padding(.horizontal,20)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.top,25)
            .padding(.bottom,40)
            
            Button(action:{}){
                Text("SIGNUP")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 100)
            }.background(
                LinearGradient(gradient: .init(colors: [Color("c3"),Color("c2"),Color("c1")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(8)
                .offset(y:-70)
                .shadow(radius: 15)
                
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
   @EnvironmentObject var googleDelegate: GoogleDelegate
   static var previews: some View {
      ContentView().environmentObject(GoogleDelegate())
  }
}





struct Logo: View {
    var body: some View {
        Image("OurSpaceText")
            .resizable().aspectRatio(contentMode: .fit)
    }
}




struct forgetPasswordButton: View {
    var body: some View {
        Button(action: {}){
            Text("Forget Password?")
                .foregroundColor(.white)
        }.padding(.top,20)
    }
}

struct existingUserButton: View {

    @Binding var index : Int
    var body: some View {
        
        Button(action: {
            withAnimation(.spring(response:0.8, dampingFraction: 0.5,blendDuration: 0.5)){
                self.index = 0
            }
            
        }){
            Text("Existing")
                .foregroundColor(self.index == 0 ? .black : .white)
                .fontWeight(.bold)
                .padding(.vertical,10)
                .frame(width: (UIScreen.main.bounds.width - 50) / 2)
        }.background(self.index == 0 ? Color.white : Color.clear)
        .clipShape(Capsule())
    }
}

struct newUserButton: View {
    @Binding var index : Int
    var body: some View {
        Button(action: {
            withAnimation(.spring(response:0.8, dampingFraction: 0.5,blendDuration: 0.5)){
                self.index = 1
            }
        }){
            Text("New")
                .foregroundColor(self.index == 1 ? .black : .white)
                .fontWeight(.bold)
                .padding(.vertical,10)
                .frame(width: (UIScreen.main.bounds.width - 50) / 2)
        }.background(self.index == 1 ? Color.white : Color.clear)
        .clipShape(Capsule())
    }
}

struct orDivider: View {
    var body: some View {
        HStack{
            Color.white.opacity(0.7)
                .frame(width: 35, height: 1)
            
            Text("Or")
                .foregroundColor(.white)
            Color.white.opacity(0.7)
                .frame(width: 35, height: 1)
        }.padding(.top,10)
    }
}

struct signOutButton: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var body: some View {
        Button(action: {
            GIDSignIn.sharedInstance().signOut()
            googleDelegate.signedIn = false
        }){
            Text("Sign Out")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding(.vertical,10)
                .frame(width: (UIScreen.main.bounds.width - 50) / 2)
        }.background(Color.clear)
        .clipShape(Capsule())
    }
}

struct passwordField: View {
    @Binding var password:String
    @Binding var passwordVisible:Bool
    var body: some View {
        HStack(spacing: 15){
            
            Image(systemName: "lock")
                .resizable()
                .frame(width: 15, height: 18)
                .foregroundColor(.black)
                .offset(x:4)
            VStack{
                if self.passwordVisible{
                    TextField("Password",text:self.$password)
                        .frame(height: 40)
                        .offset(x:5)
                }else{
                    SecureField("Password",text:self.$password)
                        .frame(height: 40)
                        .offset(x:5)
                }
            }
            Button(action: {
                self.passwordVisible.toggle()
            }){
                Image(systemName: self.passwordVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.black)
            }
        }.padding(.vertical,20)
    }
}
