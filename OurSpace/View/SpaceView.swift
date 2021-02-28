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
    @Binding var space: currentSpace
    
    var body: some View {
        
        VStack{
            
            HStack{
                
                Text(space.name)
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
            
            VStack(spacing: 20){
                
                spaceFunction(space: space, txt: "Photo").shadow(radius: 2)
                
                spaceFunction(space: space, txt: "Log").shadow(radius: 2)
                
                spaceFunction(space: space, txt: "Anniversary").shadow(radius: 2)
                
            }.padding()
            .padding(.top,30)
            Spacer()
        }
    }
}


struct spaceFunction : View{

    var space: currentSpace
    var txt: String
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var body: some View{
        HStack{
            
            Spacer()
            Text(" ")
            Text(" ")
            Text(txt)
            Text(" ")
            Text(" ")
            Spacer()
            
            
        
        }.padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        .animation(.spring())
    }
}
