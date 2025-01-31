//
//  ProductListViewModel.swift
//  Swipe_Assignment
//
//  Created by Prince Yadav on 31/01/25.
//


import Foundation
import Combine
import CoreData

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        fetchProducts()
    }
    
    func fetchProducts() {
        isLoading = true
        networkService.fetchProducts()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure = completion {
                    self?.loadLocalProducts()
                }
            }, receiveValue: { [weak self] fetchedProducts in
                self?.products = fetchedProducts.sorted { $0.isFavorite && !$1.isFavorite }
                self?.saveProductsLocally(fetchedProducts)
            })
            .store(in: &cancellables)
    }
    
    private func saveProductsLocally(_ products: [Product]) {
        coreDataManager.saveProducts(products)
    }
    
    private func loadLocalProducts() {
        products = coreDataManager.fetchProducts()
    }
    
    func toggleFavorite(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].isFavorite.toggle()
            coreDataManager.updateProductFavorite(product)
        }
    }
    
    var filteredProducts: [Product] {
        products.filter { product in
            searchText.isEmpty ||
            product.productName.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.isFavorite && !$1.isFavorite }
    }
}