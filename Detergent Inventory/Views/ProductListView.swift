//
//  ProductListView.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 10/10/26.
//

import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var store: InventoryStore
    @State private var showingAddProduct = false
    @State private var productToEdit: Product?
    
    var body: some View {
        VStack(spacing: 0) {
            if store.products.isEmpty {
                emptyState
            } else {
                productList
            }
        }
        .background(Color.white)
        .navigationTitle("Products")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddProduct = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showingAddProduct) {
            AddEditProductView(mode: .add)
                .environmentObject(store)
        }
        .sheet(item: $productToEdit) { product in
            AddEditProductView(mode: .edit(product))
                .environmentObject(store)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "shippingbox")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.secondary)
            Text("NO PRODUCTS YET")
                .font(.caption)
                .tracking(2)
                .foregroundColor(.secondary)
            Text("Tap + to add your first detergent.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Product List
    
    private var productList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.products) { product in
                    ProductRow(product: product)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            productToEdit = product
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.deleteProduct(product)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.black.opacity(0.15))
                }
            }
        }
    }
}

// MARK: - Product Row

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text("$\(String(format: "%.2f", product.pricePerUnit)) each")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(product.stock)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .monospacedDigit()
                Text("in stock")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(Color.white)
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductListView()
                .environmentObject(InventoryStore())
        }
    }
}
