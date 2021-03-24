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
    @State var spaceName:String = ""
    @State var edit = false
    @State var selectedSpaceFunc = ""
    @State var photoEdit = false
    @State var logEdit = false
    @State var newLog = false
    @State var anniversaryEdit = false
    @State var newAnniversary = false

    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    
    
    var body: some View {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            
                ZStack{
                    
                    CreateSpaceView(createEmail: $createEmail,m:$m,show:$show,spaceName:$spaceName)
                                            .opacity(selectedTab == "Create" ? 1 : 0)
                                            .alert(isPresented: $show) {
                                                Alert(title: Text(m), message: Text(""), dismissButton: .default(Text("OK")))
                                            }
                    
                    if (googleDelegate.selectedSpace.uid == ""){ //  not in a space
                        
                        DashboardView(edit: $edit).opacity(selectedTab == "Dashboard" ? 1 : 0)
                        
                    }else{                                      // in a space
                        
                        if (selectedSpaceFunc == ""){           // func not selected
                            
                            SpaceView(selectedSpaceFunc: $selectedSpaceFunc)
                                .opacity(selectedTab == "Dashboard" ? 1 : 0)
                            
                        }
                        else if (selectedSpaceFunc == "Photo"){ //in photo function
                            
                            PhotoView(selectedSpaceFunc: $selectedSpaceFunc,photoEdit: $photoEdit)
                                .opacity(selectedTab == "Dashboard" ? 1 : 0)
                            
                        }
                        else if (selectedSpaceFunc == "Log"){   //in log functio
                            if newLog{
                                LogCreate(newLog: $newLog)
                                    .opacity(selectedTab == "Dashboard" ? 1 : 0)
                            }else if googleDelegate.selectedLog.id != ""{   // viewing log
                                LogDetailView()
                                    .opacity(selectedTab == "Dashboard" ? 1 : 0)
                            }else{
                                LogView(selectedSpaceFunc: $selectedSpaceFunc, logEdit: $logEdit, newLog: $newLog)
                                    .opacity(selectedTab == "Dashboard" ? 1 : 0)
                            }
                            
                            
                        }
                        else if (selectedSpaceFunc == "Anniversary"){   //in anniversary function
                            if newAnniversary{
                                AnniversaryCreate(newAnniversary: $newAnniversary)
                                    .opacity(selectedTab == "Dashboard" ? 1 : 0)
                            }else{
                                AnniversaryView(selectedSpaceFunc: $selectedSpaceFunc,anniversaryEdit: $anniversaryEdit, newAnniversary: $newAnniversary)
                                    .opacity(selectedTab == "Dashboard" ? 1 : 0)
                            }
                            
                            
                        }
                        
                    }
                    
                    SettingsView(logedin: $logedin,index:$index,loginemail:$loginemail, loginpassword: $loginpassword, passwordVisible: $passwordVisible,signupemail:$signupemail,signuppassword:$signuppassword,signuprepassword:$signuprepassword,signuppasswordVisible: $signuppasswordVisible,signuprepasswordVisible: $signuprepasswordVisible,forgetemail: $forgetemail)
                        .opacity(selectedTab == "Settings" ? 1 : 0)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                if googleDelegate.showTabbar {
                    CustomTabbar(selectedTab: $selectedTab, edit: $edit, selectedSpaceFunc: $selectedSpaceFunc)
                        .padding(.bottom,edges!.bottom == 0 ? 15 : 0)
                        .padding(.horizontal,10)
                }
                
            
        }
        .ignoresSafeArea(.all, edges: .top)
        
        
    }
    
    

}
