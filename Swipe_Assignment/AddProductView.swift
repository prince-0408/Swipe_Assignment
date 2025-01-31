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
    @State private var animateGradient: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("Color1").opacity(0.6),
                        Color("Color").opacity(0.6)
                    ]),
                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                )
                .edgesIgnoringSafeArea(.all)
                .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true))
                .onAppear {
                    animateGradient.toggle()
                }
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add New Product")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Fill in the details of your product")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Product Details Card
                        VStack(spacing: 16) {
                            // Product Type Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Product Type")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Menu {
                                    ForEach(ProductType.allCases, id: \.self) { type in
                                        Button(type.rawValue) {
                                            viewModel.selectedType = type
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(viewModel.selectedType.rawValue)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Text Fields
                            CustomTextField(
                                icon: "tag",
                                title: "Product Name",
                                text: $viewModel.productName
                            )
                            
                            CustomTextField(
                                icon: "dollarsign.circle",
                                title: "Price",
                                text: $viewModel.price,
                                keyboardType: .decimalPad
                            )
                            
                            CustomTextField(
                                icon: "percent",
                                title: "Tax Rate",
                                text: $viewModel.tax,
                                keyboardType: .decimalPad
                            )
                            
                            // Image Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Product Image")
                                    .font(.headline)
                                
                                Button(action: {
                                    viewModel.showImagePicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text(viewModel.selectedImage == nil
                                             ? "Select Image"
                                             : "Change Image")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                
                                if let image = viewModel.selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                        .shadow(radius: 10)
                                        .transition(.scale)
                                }
                            }
                            
                            // Save Button
                            Button(action: viewModel.saveProduct) {
                                Text("Save Product")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.1))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .padding()
                    }
                }
                .navigationBarHidden(true)
            }
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

// Custom TextField Component
struct CustomTextField: View {
    let icon: String
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
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
