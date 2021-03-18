//
//  ImageDetailView.swift
//  OurSpace
//
//  Created by levi6y on 2021/3/4.
//

import SwiftUI
import SDWebImageSwiftUI
struct ImageDetailView:View {
    @EnvironmentObject var googledelegate: GoogleDelegate
    @GestureState var draggingOffset: CGSize = .zero
    var body: some View{
        ZStack{
            
            
            ScrollView(.init()){
                TabView(selection: $googledelegate.selectedImageID){
                    ForEach(googledelegate.imagesURL, id:\.self){i in
                        WebImage(url: URL(string: i)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(googledelegate.selectedImageID == i ? (googledelegate.imageScale > 1 ? googledelegate.imageScale : 1) : 1)
                            .offset(googledelegate.imageViewerOffset)
                            .gesture(
                                
                                MagnificationGesture().onChanged({ (value) in
                                    googledelegate.imageScale =  value
                                }).onEnded({ (_) in
                                    withAnimation{
                                        googledelegate.imageScale =  1
                                    }
                                })
                                //double tap to zoom
                                .simultaneously(with: TapGesture(count: 2).onEnded({
                                    withAnimation{
                                        googledelegate.imageScale = googledelegate.imageScale > 1 ? 1 : 2
                                    }
                                }))
                                
                            )
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .overlay(Button(action: {
                    withAnimation(.default){
                        googledelegate.showingViewer = false
                        googledelegate.showTabbar = true
                    }
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.35))
                        .clipShape(Circle())
                }).padding(10)
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
                .opacity(googledelegate.bgOpacity)
                ,alignment: .topTrailing
                )
            }
            .ignoresSafeArea()
            
            
        }
        .gesture(DragGesture().updating($draggingOffset, body: {(value, outValue, _) in
            outValue = value.translation
            
                
            googledelegate.onChange(value: draggingOffset)
            
        }).onEnded{(v) in
            
            
            googledelegate.onEnd(value:v)
            
            
                
        })//.transition(.move(edge: .bottom))
    }
    
}
