//
//  LogDetailView.swift
//  OurSpace
//
//  Created by levi6y on 2021/3/6.
//



import SwiftUI

struct LogDetailView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var edges = UIApplication.shared.windows.first?.safeAreaInsets

    var body: some View {
        
        VStack{
            
            HStack{
                
                Text("Log: " + googleDelegate.selectedLog.title)
                    .font(.title)
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
                HStack{
                    VStack(alignment: .leading){
                        Text(googleDelegate.selectedLog.content)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    
                    Spacer()
                    
                }.padding()
                
            }.padding(.top,30)
            .padding()
            .background(Color.clear)


            
            Spacer()
            
            backButton().padding(.bottom,100)
        }
    }
    struct backButton: View {
        @EnvironmentObject var googleDelegate: GoogleDelegate
        
        var body: some View {
            Button(action: {
                withAnimation(){
                    googleDelegate.selectedLog = mylog(id: "", title: "", content: "", spaceuid: "")
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

