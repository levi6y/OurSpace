//
//  CustomTabbar.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/3.
//
import SwiftUI

struct CustomTabbar: View {
    @Binding var selectedTab : String
    
    var body: some View {
        
        HStack(spacing: 65){
            
            TabButton(title: "Create", selectedTab: $selectedTab)
            
            TabButton(title: "Dashboard", selectedTab: $selectedTab)
            TabButton(title: "Settings", selectedTab: $selectedTab)
        }
        .padding(.horizontal)
        .background(Color.white)
        .clipShape(Capsule())
    }
}

struct TabButton : View {
    
    var title : String
    @Binding var selectedTab : String
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var body: some View{
        
        Button(action: {
            selectedTab = title
            if title == "Create"{
                googleDelegate.trackUserListOnce()
                googleDelegate.trackSpaceListOnce()
            }else if title == "Dashboard"{
                googleDelegate.trackSpaceListOnce()
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
