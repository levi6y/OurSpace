//
//  Home.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/3.
//

import SwiftUI
import Firebase
import GoogleSignIn
struct Home: View {
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
    @State var selectedTab = "Dashboard"
    @State var createEmail = ""
    @State var m:String = "Error"
    @State var show:Bool = false
    //@State var spacelist:[Space] = [Space]()
    @State var spaceName:String = ""
    //@State var userlist:[User] = [User]()
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            
            ZStack{
                CreateSpaceView(createEmail: $createEmail,m:$m,show:$show,spaceName:$spaceName)
                    .opacity(selectedTab == "Create" ? 1 : 0)
                    .alert(isPresented: $show) {
                        Alert(title: Text(m), message: Text(""), dismissButton: .default(Text("OK")))
                    }
                DashboardView()
                    .opacity(selectedTab == "Dashboard" ? 1 : 0)
                SettingsView(logedin: $logedin,index:$index,loginemail:$loginemail, loginpassword: $loginpassword, passwordVisible: $passwordVisible,signupemail:$signupemail,signuppassword:$signuppassword,signuprepassword:$signuprepassword,signuppasswordVisible: $signuppasswordVisible,signuprepasswordVisible: $signuprepasswordVisible,forgetemail: $forgetemail)
                    .opacity(selectedTab == "Settings" ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CustomTabbar(selectedTab: $selectedTab)
                .padding(.bottom,edges!.bottom == 0 ? 15 : 0)
                .padding(.horizontal,10)
        }
        .ignoresSafeArea(.all, edges: .top)
    }
    
    

}
