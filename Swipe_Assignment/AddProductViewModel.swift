//
//  AddProductViewModel.swift
//  Swipe_Assignment
//
//  Created by Prince Yadav on 31/01/25.
//


import Foundation
import UIKit
import Combine

class AddProductViewModel: ObservableObject {
    @Published var selectedType: ProductType = .product
    @Published var productName = ""
    @Published var price = ""
    @Published var tax = ""
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    @Published var showAlert = false
    
    var alertTitle = ""
    var alertMessage = ""
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func saveProduct() {
        guard validateFields() else { return }
        
        let product = Product(
            productName: productName,
            productType: selectedType.rawValue,
            price: Double(price) ?? 0,
            tax: Double(tax) ?? 0,
            image: nil
        )
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        networkService.addProduct(product: product, image: imageData)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    self?.showErrorAlert(message: "Failed to add product")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] success in
                if success {
                    self?.showSuccessAlert()
                } else {
                    self?.showErrorAlert(message: "Product not added")
                }
            })
            .store(in: &cancellables)
    }
    
    private func validateFields() -> Bool {
        guard !productName.isEmpty else {
            showErrorAlert(message: "Product name is required")
            return false
        }
        
        guard let priceValue = Double(price), priceValue > 0 else {
            showErrorAlert(message: "Invalid price")
            return false
        }
        
        guard let taxValue = Double(tax), taxValue >= 0 else {
            showErrorAlert(message: "Invalid tax rate")
            return false
        }
        
        return true
    }
    
    private func showSuccessAlert() {
        alertTitle = "Success"
        alertMessage = "Product added successfully"
        showAlert = true
    }
    
    private func showErrorAlert(message: String) {
        alertTitle = "Error"
        alertMessage = message
        showAlert = true
    }
}