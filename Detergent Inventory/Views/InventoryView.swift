//
//  InventoryView.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 9/21/26.
//


import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var store: InventoryStore
    
    // Sorted list of (type, count) for a stable display order
    private var sortedInventory: [(type: String, count: Int)] {
        store.inventoryByType
            .map { (type: $0.key, count: $0.value) }
            .sorted { $0.type < $1.type }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Total Buckets Header
            VStack(spacing: 8) {
                Text("BUCKETS IN STOCK")
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.secondary)
                Text("\(store.bucketsInStock)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(Color.white)
            .overlay(
                Rectangle().frame(height: 1).foregroundColor(.black),
                alignment: .bottom
            )
            
            // MARK: - Per-Type Inventory List
            if sortedInventory.isEmpty {
                Spacer()
                Text("No inventory recorded yet.")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text("INVENTORY BY TYPE")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(sortedInventory, id: \.type) { item in
                                InventoryRow(type: item.type, count: item.count)
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
    }
}

struct InventoryRow: View {
    let type: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(type)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            Spacer()
            Text("\(count)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .monospacedDigit()
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
            .environmentObject(InventoryStore())
    }
}