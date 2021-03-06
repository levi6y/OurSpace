//
//  LogCreate.swift
//  OurSpace
//
//  Created by levi6y on 2021/3/6.
//


import SwiftUI

struct LogCreate: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @Binding var newLog: Bool
    @State var logTitle: String = ""
    @State var logContent: String = ""
    
    var body: some View {
        
        VStack{
            
            HStack{
                
                Text(googleDelegate.selectedSpace.name + " (New Log)")
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
            
            VStack{
                VStack{
                    TextField("Title", text: $logTitle)
                        .foregroundColor(Color("c3"))
                        .lineLimit(1)
                }.padding(.vertical)
                .padding(.horizontal,20)
                .background(Color.white)
                .cornerRadius(10)

                .shadow(radius: 5)
                Text("Content")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                VStack{
                    
                    TextEditor(text: $logContent)
                        .foregroundColor(Color("c3"))
                }.padding(.vertical)
                .padding(.horizontal,20)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.bottom,40)
                .shadow(radius: 5)
                
                
                
            }.padding()
            .padding(.top,30)
            
            
            Spacer()
            
            HStack{
                backButton(newLog: $newLog)
                createButton(newLog: $newLog,t:$logTitle,c: $logContent)
            }.padding(.bottom,100)
        }.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    struct backButton: View {
        @EnvironmentObject var googleDelegate: GoogleDelegate
        @Binding var newLog: Bool
        
        var body: some View {
            Button(action: {
                withAnimation(){
                    newLog = false
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
    struct createButton: View {
        @EnvironmentObject var googleDelegate: GoogleDelegate
        @Binding var newLog:Bool
        @Binding var t: String
        @Binding var c: String
        var body: some View {
            Button(action: {
                var _ = googleDelegate.createLog(title: t, content: c)
                    .done{ r in
                        if r {
                            googleDelegate.getLogs()
                            t = ""
                            c = ""
                            withAnimation(){
                                newLog = false
                            }
                        }
                    }
            }){
                Text("Create")
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

