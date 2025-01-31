//
//  AddProductView.swift
//  Swipe_Assignment
//
//  Created by Prince Yadav on 31/01/25.
//


import SwiftUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Product Type", selection: $viewModel.selectedType) {
                    ForEach(ProductType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                TextField("Product Name", text: $viewModel.productName)
                TextField("Price", text: $viewModel.price)
                    .keyboardType(.decimalPad)
                TextField("Tax Rate", text: $viewModel.tax)
                    .keyboardType(.decimalPad)
                
                Button("Select Image") {
                    viewModel.showImagePicker = true
                }
                
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") { viewModel.saveProduct() }
            )
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.alertTitle),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}