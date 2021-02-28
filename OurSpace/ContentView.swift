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
    @State var logedin: Bool = UserDefaults.standard.bool(forKey: "logedin")
    @State var loginemail: String = ""
    @State var loginpassword: String = ""
    @State var signupemail: String = ""
    @State var signuppassword: String = ""
    @State var signuprepassword: String = ""
    @State var alertMessage = "Something is wrong."
    @State var showingAlert = false
    @State var forgetemail = ""

    
    var body: some View {
        
        Group{
            
            ZStack{
                LinearGradient(gradient: .init(colors: [Color("c1"),Color("c2"),Color("c3")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                
                if logedin || googleDelegate.signedIn{
                    
                    Home(logedin: $logedin,index:$index,loginemail:$loginemail, loginpassword: $loginpassword, passwordVisible: $loginpasswordVisible,signupemail:$signupemail,signuppassword:$signuppassword,signuprepassword:$signuprepassword,signuppasswordVisible: $signuppasswordVisible,signuprepasswordVisible: $signuprepasswordVisible,forgetemail: $forgetemail)
                    
                    
                }else{

                    
                    VStack{
                        
                        Logo()
                        Spacer()
                        HStack{
                            existingUserButton(index: $index)
                            newUserButton(index: $index)
                            forgetPasswordButton(index: $index)
                        }.background(Color.black.opacity(0.1))
                        .clipShape(Capsule())
                        .padding(.top,25)
                        
                        if self.index == 0{
                            Login(loginemail:$loginemail, loginpassword: $loginpassword, passwordVisible: $loginpasswordVisible,showingAlert:$showingAlert,logedin:$logedin,alertMessage:$alertMessage,index:$index).alert(isPresented: $showingAlert) {
                                Alert(title: Text(alertMessage), message: Text(""), dismissButton: .default(Text("OK")))
                            }
                            
                            
                            
                        }else if self.index == 1{
                            SignUp(signupemail:$signupemail,signuppassword:$signuppassword,signuprepassword:$signuprepassword,signuppasswordVisible: $signuppasswordVisible,signuprepasswordVisible: $signuprepasswordVisible,logedin:$logedin,alertMessage:$alertMessage,showingAlert:$showingAlert,index:$index,loginemail:$loginemail, loginpassword: $loginpassword, passwordVisible: $loginpasswordVisible,forgetemail: $forgetemail).alert(isPresented: $showingAlert) {
                                Alert(title: Text(alertMessage), message: Text(""), dismissButton: .default(Text("OK")))
                            }
                            Spacer(minLength: 100)
                        }else if self.index == 2{
                            Forget(forgetemail:$forgetemail,showingAlert:$showingAlert,alertMessage:$alertMessage,index:$index).alert(isPresented: $showingAlert) {
                                Alert(title: Text(alertMessage), message: Text(""), dismissButton: .default(Text("OK")))
                            }
                            Spacer(minLength: 200)
                        }
                        if self.index == 0{
                            orDivider()
                            
                            GoogleSignInButton()
                        }
                        
                        Spacer()
                    }.padding()
                    
                }
                if googleDelegate.isLoading {
                    
                    GeometryReader{_ in
                        
                        Loader()
                        
                    }.alignmentGuide(HorizontalAlignment.center){_ in 80}
                    .alignmentGuide(VerticalAlignment.center){_ in 60}
                    .background(LinearGradient(gradient: .init(colors: [Color("c1"),Color("c2"),Color("c3")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
                    .shadow(radius: 5)
    
                }
                
            }
        }.onAppear{
            
            GIDSignIn.sharedInstance().restorePreviousSignIn()
        } // uncomment to run on real device.
        
        
        
        
        
        
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


func hideKeyboard(){
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

struct Login : View {
    @Binding var loginemail: String
    @Binding var loginpassword: String
    @Binding var passwordVisible: Bool
    @Binding var showingAlert: Bool
    @Binding var logedin: Bool
    @Binding var alertMessage: String
    @Binding var index: Int

    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    func login(){
        hideKeyboard()
        googleDelegate.isLoading = true
        
        Auth.auth().signIn(withEmail: loginemail, password: loginpassword) { (result, error) in
            if error != nil {
                logedin = false
                UserDefaults.standard.set(logedin,forKey: "logedin")
                alertMessage = error?.localizedDescription ?? ""
                googleDelegate.isLoading = false
                showingAlert = true
            }else{
                let currentUser = Auth.auth().currentUser!
                if !currentUser.isEmailVerified{
                    logedin = false
                    UserDefaults.standard.set(logedin,forKey: "logedin")
                    alertMessage = "An email has been sent to your email address, please check and verify your email address!"
                    googleDelegate.isLoading = false
                    showingAlert = true
                
                }else{
                    let currentUser = Auth.auth().currentUser!
                    fetchUser(uid: currentUser.uid) { (user) in
                        googleDelegate.user = user
                    }
                    logedin = true
                    UserDefaults.standard.set(logedin,forKey: "logedin")
                    googleDelegate.isLoading = false
                    print("Signed in with email")
                    
                    
                }
            }
        }
    }
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
            .shadow(radius: 5)
            
            Button(action:{
                login()
            }){
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

struct Forget : View {
    
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @Binding var forgetemail: String
    @Binding var showingAlert: Bool
    @Binding var alertMessage: String
    @Binding var index: Int

    func forget(){
        hideKeyboard()
        googleDelegate.isLoading = true
        if forgetemail == ""{
            alertMessage = "Please enter email address!"
            googleDelegate.isLoading = false
            showingAlert = true
            return
        }
        
        
        Auth.auth().sendPasswordReset(withEmail: forgetemail) { error in
            if error != nil{
                alertMessage = error?.localizedDescription ?? ""
                forgetemail = ""
                googleDelegate.isLoading = false
                showingAlert = true
            }else{
                alertMessage = "Email Sent!"
                forgetemail = ""
                googleDelegate.isLoading = false
                showingAlert = true
            }
        }
        
    }
    var body : some View{
        VStack{
            VStack{
                HStack(spacing: 15){
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    TextField("Enter Email Address", text: self.$forgetemail)
                }.padding(.vertical,20)
            }.padding(.vertical)
            .padding(.horizontal,20)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.top,25)
            .padding(.bottom,40)
            .shadow(radius: 5)
            
            Button(action:{
                forget()
            }){
                Text("Send Email")
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
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @Binding var signupemail: String
    @Binding var signuppassword: String
    @Binding var signuprepassword: String
    @Binding var signuppasswordVisible: Bool
    @Binding var signuprepasswordVisible: Bool
    @Binding var logedin: Bool
    @Binding var alertMessage: String
    @Binding var showingAlert: Bool
    @Binding var index: Int
    @Binding var loginemail: String
    @Binding var loginpassword: String
    @Binding var passwordVisible: Bool
    @Binding var forgetemail: String

    func validateForm() -> Bool{
        
        var valid = true
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if signupemail.isEmpty || signuppassword.isEmpty || signuprepassword.isEmpty {
            alertMessage = "Please fill in all the forms."
            showingAlert = true
            valid = false
        }else if !(emailTest.evaluate(with: signupemail)){
            alertMessage = "Invalid Email address."
            showingAlert = true
            valid = false
        }else if signuppassword.count <= 5 {
            alertMessage = "Password too short."
            showingAlert = true
            valid = false
        }else if !(signuppassword == signuprepassword){
            alertMessage = "Those passwords didn't match."
            showingAlert = true
            valid = false
        }
        
        return valid
    }
    func signout(){
        
        do {
            try Auth.auth().signOut()
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
        } catch let signOutError as NSError {
            alertMessage = signOutError.localizedDescription
            logedin = false
            UserDefaults.standard.set(logedin,forKey: "logedin")
            googleDelegate.isLoading = false
            showingAlert = true
        }
        
        googleDelegate.isLoading = false

    }
    func signup(){
        hideKeyboard()
        googleDelegate.isLoading = true
        if !validateForm(){
            googleDelegate.isLoading = false
            return
        }
        
        Auth.auth().createUser(withEmail: signupemail, password: signuppassword){ (result, error) in
            if error != nil {
                alertMessage = error?.localizedDescription ?? ""
                googleDelegate.isLoading = false
                showingAlert = true
            }else{
                let currentUser = Auth.auth().currentUser!
                var databasereference: DatabaseReference!
                databasereference = Database.database().reference()
                databasereference.child("users/\(currentUser.uid)/uid").setValue(currentUser.uid)
                databasereference.child("users/\(currentUser.uid)/email").setValue(currentUser.email!)
                databasereference.child("users/\(currentUser.uid)/userName").setValue(currentUser.email!)
                databasereference.child("users/\(currentUser.uid)/pic").setValue("0")
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if(error != nil){
                        signout()
                        alertMessage = error!.localizedDescription
                        showingAlert = true
                    }else{
                        signout()
                        alertMessage = "You created a new account, before logging in, please verify your email address! (An email has been sent to your email address)"
                        showingAlert = true
                    }
                }
            }
        }
    }
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
            .shadow(radius: 5)
            
            Button(action:{
                signup()
            }){
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

struct Logo: View {
    var body: some View {
        Image("OurSpaceText")
            .resizable().aspectRatio(contentMode: .fit)
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
                .frame(width: (UIScreen.main.bounds.width - 50) / 3)
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
                .frame(width: (UIScreen.main.bounds.width - 50) / 3)
        }.background(self.index == 1 ? Color.white : Color.clear)
        .clipShape(Capsule())
    }
}

struct forgetPasswordButton: View {

    @Binding var index : Int
    var body: some View {
        
        Button(action: {
            withAnimation(.spring(response:0.8, dampingFraction: 0.5,blendDuration: 0.5)){
                self.index = 2
            }
            
        }){
            Text("Forget")
                .foregroundColor(self.index == 2 ? .black : .white)
                .fontWeight(.bold)
                .padding(.vertical,10)
                .frame(width: (UIScreen.main.bounds.width - 50) / 3)
        }.background(self.index == 2 ? Color.white : Color.clear)
        .clipShape(Capsule())
    }
}

struct orDivider: View {
    var body: some View {
        HStack{
            Color.white.opacity(0.7)
                .frame(width: 35, height: 1)
            
            Text("Or")
                .fontWeight(.bold)
                .foregroundColor(.white)
            Color.white.opacity(0.7)
                .frame(width: 35, height: 1)
        }.padding(.top,10)
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
//
//struct ContentView_Previews: PreviewProvider {
//   @EnvironmentObject var googleDelegate: GoogleDelegate
//   static var previews: some View {
//      ContentView().environmentObject(GoogleDelegate())
//  }
//}



