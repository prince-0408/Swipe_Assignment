//
//  NetworkService.swift
//  Swipe_Assignment
//
//  Created by Prince Yadav on 31/01/25.
//


import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://app.getswipe.in/api/public"
    
    func fetchProducts() -> AnyPublisher<[Product], Error> {
        guard let url = URL(string: "\(baseURL)/get") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func addProduct(product: Product, image: Data?) -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: "\(baseURL)/add") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add form fields
        let fields = [
            "product_name": product.productName,
            "product_type": product.productType,
            "price": "\(product.price)",
            "tax": "\(product.tax)"
        ]
        
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add image if exists
        if let imageData = image {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in true }
            .catch { error -> AnyPublisher<Bool, Error> in
                return Just(false)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
