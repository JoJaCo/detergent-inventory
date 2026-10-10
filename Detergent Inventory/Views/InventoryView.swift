//
//  InventoryView.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 10/10/26.
//

import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var store: InventoryStore
    
    /// Products sorted alphabetically, or by stock descending. Pick one.
    private var sortedProducts: [Product] {
        store.products.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Total Stock Header
            VStack(spacing: 8) {
                Text("BUCKETS IN STOCK")
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.secondary)
                
                if store.totalStock == 0 {
                    Text("NO INVENTORY")
                        .font(.system(size: 24, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.black)
                        .padding(.vertical, 12)
                } else {
                    Text("\(store.totalStock)")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(Color.white)
            .overlay(
                Rectangle().frame(height: 1).foregroundColor(.black),
                alignment: .bottom
            )
            
            // MARK: - Product List
            if sortedProducts.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.secondary)
                    Text("No products yet.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text("INVENTORY BY PRODUCT")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(sortedProducts) { product in
                                InventoryProductRow(product: product)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.black.opacity(0.15))
                            }
                        }
                    }
                }
                .background(Color.white)
            }
        }
        .background(Color.white)
        .navigationTitle("Inventory")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Product Row

struct InventoryProductRow: View {
    let product: Product
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                Text("$\(String(format: "%.2f", product.pricePerUnit)) each")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(product.stock)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(product.stock == 0 ? .secondary : .black)
                .monospacedDigit()
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InventoryView()
                .environmentObject(InventoryStore())
        }
    }
}
