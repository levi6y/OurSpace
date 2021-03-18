//
//  AnniversaryCreate.swift
//  OurSpace
//
//  Created by levi6y on 2021/3/18.
//


import SwiftUI

struct AnniversaryCreate: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @Binding var newAnniversary: Bool
    @State var anniversaryDescription: String = ""
    @State var anniversaryDate: Date = Date()
    
    var body: some View {
        
        VStack{
            
            HStack{
                
                Text(googleDelegate.selectedSpace.name + " (New Anniversary)")
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
            
            VStack{
                HStack{
                    TextField("Description", text: $anniversaryDescription)
                        .foregroundColor(Color("c3"))
                        .lineLimit(1)
                    DatePicker("", selection: $anniversaryDate, in: ...Date(), displayedComponents: .date)
                        .environment(\.timeZone, TimeZone(abbreviation: "GMT-4")!)
                }.padding(.vertical)
                .padding(.horizontal,20)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                
                
                
                
            }.padding()
            .padding(.top,30)
            
            
            Spacer()
            
            HStack{
                backButton(newAnniversay: $newAnniversary)
                createButton(newAnniversary: $newAnniversary,anniversaryDescription: $anniversaryDescription,anniversaryDate: $anniversaryDate)
            }.padding(.bottom,100)
            
        }.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    struct backButton: View {
        @EnvironmentObject var googleDelegate: GoogleDelegate
        @Binding var newAnniversay: Bool
        
        var body: some View {
            Button(action: {
                withAnimation(){
                    newAnniversay = false
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
        @Binding var newAnniversary:Bool
        @Binding var anniversaryDescription: String
        @Binding var anniversaryDate: Date
        var body: some View {
            Button(action: {
                
                var _ = googleDelegate.createAnniversary(anniversaryDescription: anniversaryDescription, anniversaryDate: anniversaryDate)
                    .done{ r in
                        if r {
                            googleDelegate.getAnniversaries()
                            anniversaryDescription = ""
                            anniversaryDate = Date()
                            withAnimation(){
                                newAnniversary = false
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

