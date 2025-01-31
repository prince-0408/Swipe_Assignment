//
//  ProductListView.swift
//  Swipe_Assignment
//
//  Created by Prince Yadav on 31/01/25.
//

import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()
    @State private var showAddProductView = false
    @State private var selectedProduct: Product?
    @State private var isDetailPresented = false

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Sophisticated Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("Color1"),
                        Color("Color")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    // Elegant Header with Add Button
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Product Catalog")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Discover our premium collection")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showAddProductView = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    // Enhanced Search Bar
                    SearchBar(text: $viewModel.searchText)
                        .padding(.horizontal)
                        .padding(.bottom)

                    if viewModel.isLoading {
                        LoadingView()
                            .frame(height: 120)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.filteredProducts) { product in
                                    ProductCard(product: product, onFavoriteToggle: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            viewModel.toggleFavorite(product)
                                        }
                                    })
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedProduct = product
                                            isDetailPresented = true
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.fetchProducts()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddProductView) {
            AddProductView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isDetailPresented) {
            if let product = selectedProduct {
                ProductDetailView(product: product)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: product.image ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .cornerRadius(10)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 180)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.productName)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Text(product.productType)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Button(action: onFavoriteToggle) {
                    HStack {
                        Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        Text(product.isFavorite ? "Favorited" : "Favorite")
                    }
                    .foregroundColor(product.isFavorite ? .red : .primary)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search Products", text: $text)
                .font(.system(size: 16))
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading products...")
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.9))
    }
}

struct ProductDetailView: View {
    let product: Product
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: product.image ?? "")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(product.productName)
                            .font(.title)
                            .bold()
                        
                        Text(product.productType)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Price")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.title2)
                                    .bold()
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Tax")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(product.tax, specifier: "%.1f")%")
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
            .environmentObject(ProductListViewModel())
            .preferredColorScheme(.light)
    }
}
