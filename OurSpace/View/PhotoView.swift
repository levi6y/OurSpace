//
//  PhotoView.swift
//  OurSpace
//
//  Created by levi6y on 2021/3/2.
//
import SwiftUI
import Firebase
import GoogleSignIn
import SDWebImageSwiftUI
struct PhotoView: View {
    
    @EnvironmentObject var googleDelegate: GoogleDelegate
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @Binding var selectedSpaceFunc: String
    @Binding var photoEdit: Bool
    
    var body: some View {
        
        VStack{
            
            HStack{
                
                Text(googleDelegate.selectedSpace.name + " (Photos)")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
                Button(action: {
                    googleDelegate.getPhotosURL()
                    photoEdit = false
                    
                    
                }) {
                    
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }.padding(.trailing,10)
                Button(action: {
                    
                    photoEdit.toggle()
                    
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
                
                VStack(spacing: photoEdit ? 65 : 25){
                    
                    if (!googleDelegate.isLoading && googleDelegate.images.count > 0){
                        ForEach(self.googleDelegate.images){ i in
                            
                            ImageView(image: i,photoEdit: $photoEdit, image2: UIImage())
                            
                            
                        }
                    }
                    
                    
                    
                    
                }
                
            }.shadow(radius: 5)
            
            
            Spacer()
            HStack{
                backButton(selectedSpaceFunc: $selectedSpaceFunc)
                uploadButton()
                
            }.padding(.bottom,100)
            
        }.overlay(
            ZStack{
                if googleDelegate.showingViewer && !googleDelegate.isLoading{
                    
                    Color.black
                        .opacity(googleDelegate.bgOpacity)
                        .ignoresSafeArea()
                    
                    ImageDetailView()
                }
            }
        ).sheet(isPresented: $googleDelegate.picker2) {
            
            ImagePicker(picker: $googleDelegate.picker2, img_Data: $googleDelegate.img_data2)
        }
        .onChange(of: googleDelegate.img_data2) { (newData) in
            // whenever image is selected update image in Firebase...
            googleDelegate.uploadPhoto()
            
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
        
        var body: some View {
            Button(action: {
                googleDelegate.picker2.toggle()
            }){
                Text("Upload")
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
