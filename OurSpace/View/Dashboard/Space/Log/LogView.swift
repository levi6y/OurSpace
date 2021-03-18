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
    @Binding var logEdit: Bool
    @Binding var newLog: Bool
    var body: some View {
        
        VStack{
            
            HStack{
                
                Text(googleDelegate.selectedSpace.name + " (Logs)")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
                Button(action: {
                    googleDelegate.getLogs()
                    logEdit = false
                    
                    
                }) {
                    
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }.padding(.trailing,10)
                Button(action: {
                    
                    logEdit.toggle()
                    
                }) {
                    
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }.padding(.trailing ,10)
            }
            .padding()
            .padding(.top,edges!.top)
            // Top Shadow Effect...
            .background(Color("c2"))
            .shadow(color: Color.white.opacity(0.06), radius: 5, x: 0, y: 5)
            
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 20){
                    
                    
                    if (!googleDelegate.isLoading && googleDelegate.logs.count > 0){
                        ForEach(self.googleDelegate.logs){ l in
                            
                            
                            logcellview(logEdit: logEdit, data: l).onTapGesture {
                                withAnimation(.spring()){
                                    googleDelegate.selectedLog = l
                                }
                                
                            }
                            
                        }
                    }
                }.padding()
                
            }.shadow(radius: 5).padding(.top, 30)
            
            
            Spacer()
            
            HStack{
                backButton(selectedSpaceFunc: $selectedSpaceFunc)
                uploadButton(newLog: $newLog)
                
            }.padding(.bottom,100)
        }
    }
    struct backButton: View {
        @EnvironmentObject var googleDelegate: GoogleDelegate
        @Binding var selectedSpaceFunc: String
        
        var body: some View {
            Button(action: {
                withAnimation(.spring()){
                    selectedSpaceFunc = ""
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
    struct uploadButton: View {
        @EnvironmentObject var googleDelegate: GoogleDelegate
        @Binding var newLog:Bool
        var body: some View {
            Button(action: {
                withAnimation(.spring()){
                    newLog = true
                }
                
            }){
                Text("New Log")
                    .foregroundColor(Color("c3"))
                    .fontWeight(.bold)
                    .padding(.vertical,10)
                    .frame(width: (UIScreen.main.bounds.width - 50) / 2)
            }.background(Color.white)
            .clipShape(Capsule())
            .shadow(radius: 5)
        }
    }
    
    struct logcellview : View{
        var logEdit: Bool
        var data: mylog
        @EnvironmentObject var googleDelegate: GoogleDelegate
        var body: some View{
            HStack{
                VStack(alignment: .leading, spacing: 5){
                    Text(data.title)
                        .foregroundColor(Color("c3"))
                        .fontWeight(.bold)
                }
                
                
                Spacer()
                
                if logEdit{
                    Button(action: {
                        if self.data.id != ""{
                            
                            self.googleDelegate.deleteLog(uid: self.data.id)
                        }
                    }){
                        Image(systemName: "minus.circle")
                    }.foregroundColor(.red)
                }
                
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
            .animation(.spring())
            
            
        }
    }

}

