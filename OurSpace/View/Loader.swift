//
//  Loader.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/19.
//
import SwiftUI

struct Loader: View {
    
    @State var animate = false
    
    var body: some View {
        VStack{
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(AngularGradient(gradient: .init(colors: [Color("c1"),Color("c2"),Color("c3")]), center: .center),style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 45, height: 45)
                .rotationEffect(.init(degrees: self.animate ? 360 : 0))
                .animation(Animation.linear(duration: 0.7)
                            .repeatForever(autoreverses: false))
            Text("Please Wait...")
                .foregroundColor(Color("c3"))
                .fontWeight(.bold)
                .padding(.top,10)
            
        }
        .padding(20)
        .frame(width: 160, height: 120)
        .background(Color.white)
        .cornerRadius(15)
        .onAppear{
            self.animate.toggle()
        }
        
        
        
    }
}
