//
//  ImageView.swift
//  OurSpace
//
//  Created by levi6y on 2021/3/2.
//

import SwiftUI
import SDWebImageSwiftUI
struct ImageView: View {
    @EnvironmentObject var googledelegate: GoogleDelegate
    var image: image
    @Binding var photoEdit: Bool
    var body: some View{
        HStack{
            ZStack{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                WebImage(url: URL(string: image.URL)!)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: photoEdit ? (getRect().width - 100) : (getRect().width - 50) , height: photoEdit ? (getRect().width - 100)*0.9 : (getRect().width - 50)*0.9)
                    .cornerRadius(12)
                    
                
            }
            if photoEdit{
                Button(action: {
                    googledelegate.deletePhoto(ref: image.ref)
                }){
                    Image(systemName: "minus.circle").font(.title)
                }.foregroundColor(.red)
            }
            
        }.animation(.spring())
        
    }
}
extension View{
    func getRect()->CGRect{
        return UIScreen.main.bounds
    }
}
