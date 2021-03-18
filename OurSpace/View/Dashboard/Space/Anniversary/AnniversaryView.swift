//
//  AnniversaryView.swift
//  OurSpace
//
//  Created by levi6y on 2021/3/2.
//
import SwiftUI

struct AnniversaryView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @Binding var selectedSpaceFunc: String
    @Binding var anniversaryEdit: Bool
    @Binding var newAnniversary: Bool
    var body: some View {
        
        VStack{
            
            HStack{
                
                Text(googleDelegate.selectedSpace.name + " (Anniversaries)")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
                Button(action: {
                    googleDelegate.getAnniversaries()
                    anniversaryEdit = false
                    
                    
                }) {
                    
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }.padding(.trailing,10)
                Button(action: {
                    
                    anniversaryEdit.toggle()
                    
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
                    
                    
                    if (!googleDelegate.isLoading && googleDelegate.anniversaries.count > 0){
                        ForEach(self.googleDelegate.anniversaries){ a in
                            
                            
                            anniversarycellview(anniversaryEdit: anniversaryEdit, data: a)
                            
                        }
                    }
                }.padding()
                
            }.shadow(radius: 5).padding(.top, 30)
            
            
            Spacer()
            
            
            HStack{
                backButton(selectedSpaceFunc: $selectedSpaceFunc)
                uploadButton(newAnniversary: $newAnniversary)
                
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
    struct anniversarycellview : View{
        var anniversaryEdit: Bool
        var data: mydate
        @EnvironmentObject var googleDelegate: GoogleDelegate
        var body: some View{
            HStack{
                Text(data.description)
                    .foregroundColor(Color("c3"))
                    .fontWeight(.bold)
                
                
                Spacer()
                Text(data.text)
                    .foregroundColor(Color("c3"))
                    .fontWeight(.bold)
                if anniversaryEdit{
                    Button(action: {
                        if self.data.id != ""{
                            
                            self.googleDelegate.deleteAnniversary(uid: self.data.id)
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
    struct uploadButton: View {
        @EnvironmentObject var googleDelegate: GoogleDelegate
        @Binding var newAnniversary:Bool
        var body: some View {
            Button(action: {
                withAnimation(.spring()){
                    newAnniversary = true
                }
                
            }){
                Text("New Anniversary")
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
