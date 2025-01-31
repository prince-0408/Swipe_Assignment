//
//  Product.swift
//  Swipe_Assignment
//
//  Created by Prince Yadav on 31/01/25.
//


import Foundation

struct Product: Identifiable, Codable {
    var id: UUID? = UUID()
    let productName: String
    let productType: String
    let price: Double
    let tax: Double
    let image: String?
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productType = "product_type"
        case price
        case tax
        case image
    }
}

struct ProductResponse: Codable {
    let products: [Product]
}

enum ProductType: String, CaseIterable {
    case product = "Product"
    case service = "Service"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case others = "Others"
    case groceries = "Groceries"
}
