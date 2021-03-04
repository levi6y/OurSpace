//
//  CustomTabbar.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/3.
//
import SwiftUI

struct CustomTabbar: View {
    @Binding var selectedTab : String
    @Binding var edit: Bool
    @Binding var selectedSpaceFunc: String
    var body: some View {
        
        HStack(spacing: 65){
            
            TabButton(title: "Create", selectedTab: $selectedTab,edit:$edit, selectedSpaceFunc: $selectedSpaceFunc)
             
            TabButton(title: "Dashboard", selectedTab: $selectedTab,edit:$edit, selectedSpaceFunc: $selectedSpaceFunc)
            TabButton(title: "Settings", selectedTab: $selectedTab,edit:$edit, selectedSpaceFunc: $selectedSpaceFunc)
        }
        .padding(.horizontal)
        .background(Color.white)
        .clipShape(Capsule())
        .animation(.spring())
        .shadow(radius: 5)
    }
}

struct TabButton : View {
    
    var title : String
    @Binding var selectedTab : String
    @EnvironmentObject var googleDelegate: GoogleDelegate
    @Binding var edit: Bool
    @Binding var selectedSpaceFunc: String
    var body: some View{
        
        Button(action: {
            withAnimation(.spring()){
                selectedTab = title
            }
            
            
            if title == "Create"{
                //googleDelegate.trackUserListOnce()
                //googleDelegate.trackSpaceListOnce()
                
                edit = false
                
            }else if title == "Settings"{
                edit = false
            }
            
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            

        }) {
            
            VStack(spacing: 5){
                
                Image(title)
                    .renderingMode(.template)
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
            .foregroundColor(selectedTab == title ? Color("c2") : .gray)
            .padding(.horizontal,10)
            .padding(.vertical,10)
        }
    }
}
