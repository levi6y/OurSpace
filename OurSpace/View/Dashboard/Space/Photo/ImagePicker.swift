//
//  ImagePicker.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/3.
//


import SwiftUI
import PhotosUI

struct ImagePicker2: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var picker : Bool
    @Binding var img_Data : Data

    typealias UIViewControllerType = UIImagePickerController
    var sourceType : UIImagePickerController.SourceType = .photoLibrary
    
   
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker2

        init(_ parent: ImagePicker2) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                DispatchQueue.main.async {
                        self.parent.img_Data = uiImage.jpegData(compressionQuality: 0.5)!
                        self.parent.picker = false
                }
            } else {
                self.parent.picker = false
                return
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker2>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker2>) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }


}

struct ImagePicker : UIViewControllerRepresentable {

    @Binding var picker : Bool
    @Binding var img_Data : Data

    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {

        var config = PHPickerConfiguration()
        config.selectionLimit = 1


        let controller = PHPickerViewController(configuration: config)

        controller.delegate = context.coordinator


        return controller
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {


    }

    class Coordinator : NSObject,PHPickerViewControllerDelegate{

        var parent : ImagePicker

        init(parent : ImagePicker) {
            self.parent = parent

        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

            if results.isEmpty{
                self.parent.picker.toggle()
                return
            }

            let item = results.first!.itemProvider

            if item.canLoadObject(ofClass: UIImage.self){

                item.loadObject(ofClass: UIImage.self) { (image, err) in
                    if err != nil{return}

                    let imageData = image as! UIImage

                    DispatchQueue.main.async {
                        self.parent.img_Data = imageData.jpegData(compressionQuality: 0.5)!
                        self.parent.picker.toggle()
                    }
                }
            }
        }
    }
}
