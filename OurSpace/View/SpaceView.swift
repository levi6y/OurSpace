//
//  SpaceView.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/28.
//
import SwiftUI

struct SpaceView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @Binding var selectedSpaceFunc: String
    var body: some View {
        
        VStack{
            
            HStack{
                
                Text(googleDelegate.selectedSpace.name)
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
                    
                    spaceFunction(txt: "Photo").onTapGesture {
                        withAnimation(.spring()){
                            selectedSpaceFunc = "Photo"
                        }
                        
                        googleDelegate.getPhotosURL()
                        
                    }
                    
                    spaceFunction(txt: "Log").onTapGesture {
                        withAnimation(.spring()){
                            selectedSpaceFunc = "Log"
                        }
                    }
                    
                    spaceFunction(txt: "Anniversary").onTapGesture {
                        withAnimation(.spring()){
                            selectedSpaceFunc = "Anniversary"
                        }
                    }
                    
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
                withAnimation(.spring()){
                    selectedSpaceFunc = ""
                    googleDelegate.selectedSpace = currentSpace(id: -1,u1: "", u2: "", name: "", uid: "", numOfPhotos: 0, numOfLogs: 0, numOfAnniversaries: 0)
                }
                
                
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



struct spaceFunction : View{


    var txt: String
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var body: some View{
        
        HStack{
            Spacer()
            VStack(alignment: .leading, spacing: 5){
                Text(txt)
                    .foregroundColor(Color("c3"))
                    .fontWeight(.bold)
            }
            
            
            Spacer()
            
            
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        .animation(.spring())
        
    }
}
