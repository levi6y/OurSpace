//
//  DashboardView.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/3.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @Binding var edit: Bool

    
    var body: some View {
        VStack{
            
            HStack{
                
                Text("Dashboard")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
                Button(action: {
                    
                    _ = googleDelegate.trackSpaceListOnce2()
                        .done{_ in
                            edit = false
                            
                        }
                    
                }) {
                    
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }.padding(.trailing,10)
                Button(action: {
                    
                    self.edit.toggle()
                    
                }) {
                    
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }.padding(.trailing ,10)
            }
            .padding()
            .padding(.top,edges!.top)
            .background(Color("c2"))
            .shadow(color: Color.white.opacity(0.06), radius: 5, x: 0, y: 5)
            //Spacer(minLength: 0)
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 20){
                    
                    ForEach(self.googleDelegate.currentUsersSpaceL){ i in
                        
                        cellView(edit: edit, data: i).onTapGesture {
                            withAnimation(.spring()){
                                googleDelegate.selectedSpace = i
                            }
                            
                        }
                    }
                    
                }.padding()
                
            }.shadow(radius: 5).padding(.top, 30)
            
            
            
            
            //Spacer(minLength: 0)
            
            
            
        }
    }
}

struct cellView : View{
    var edit: Bool
    var data: currentSpace
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var body: some View{
        HStack{
        
            VStack(alignment: .leading, spacing: 5){
                Text("Space Name:").foregroundColor(Color("c3"))
                    .fontWeight(.bold).lineLimit(1)
                Text(data.name).foregroundColor(Color("c3"))
                    .fontWeight(.bold).lineLimit(1)
            }
            
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 5){
                if (data.u1 == googleDelegate.user.email){
                    Text("This is your space with:").foregroundColor(Color("c3"))
                        .fontWeight(.bold).lineLimit(1)
                    Text(data.u2).foregroundColor(Color("c3"))
                        .fontWeight(.bold).lineLimit(1)
                }else{
                    Text("This is your space with:").foregroundColor(Color("c3"))
                        .fontWeight(.bold).lineLimit(1)
                    Text(data.u1).foregroundColor(Color("c3"))
                        .fontWeight(.bold).lineLimit(1)
                }
                
            }
            if edit{
                Button(action: {
                    if self.data.uid != ""{
                        
                        self.googleDelegate.deleteSpace(uid: self.data.uid)
                    }
                }){
                    Image(systemName: "minus.circle").font(.title)
                }.foregroundColor(.red)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        .animation(.spring())
        
    }
}




