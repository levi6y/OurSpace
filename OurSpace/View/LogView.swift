//
//  LogView.swift
//  OurSpace
//
//  Created by levi6y on 2021/3/2.
//

import SwiftUI

struct LogView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @Binding var selectedSpaceFunc: String
    var body: some View {
        
        VStack{
            
            HStack{
                
                Text(googleDelegate.selectedSpace.name + " (Logs)")
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
            
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 20){
                    
                    
                    
                }.padding()
                
            }.shadow(radius: 5).padding(.top, 30)
            
            
            Spacer()
            
            backButton(selectedSpaceFunc: $selectedSpaceFunc).padding(.bottom,100)
        }
    }
    struct backButton: View {
        @EnvironmentObject var googleDelegate: GoogleDelegate
        @Binding var selectedSpaceFunc: String
        
        var body: some View {
            Button(action: {
                selectedSpaceFunc = ""
               
                
            }){
                Text("Back")
                    .foregroundColor(Color("c3"))
                    .fontWeight(.bold)
                    .padding(.vertical,10)
                    .frame(width: (UIScreen.main.bounds.width - 50) / 2)
            }.background(Color.white)
            .clipShape(Capsule())
            .shadow(radius: 5)
        }
    }
}
