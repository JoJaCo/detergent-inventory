//
//  AdjustStockView.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 9/29/26.
//

import SwiftUI

struct AdjustStockView: View {
    @EnvironmentObject var store: InventoryStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedType: String = "Laundry Detergent"
    @State private var amountText: String = ""
    @State private var showConfirmation = false
    @State private var confirmationMessage = ""
    
    let availableSupplies = [
        "Laundry Detergent",
        "Dish Soap",
        "Bleach",
        "Fabric Softener",
        "All-Purpose Cleaner",
        "Glass Cleaner",
        "Floor Cleaner",
        "Disinfectant",
        "Unsorted"
    ]
    
    /// The current count for the selected type
    private var currentCount: Int {
        store.inventoryByType[selectedType, default: 0]
    }
    
    /// The parsed new amount (nil if invalid)
    private var newAmount: Int? {
        Int(amountText)
    }
    
    /// The difference between new and current (positive = adding, negative = removing)
    private var difference: Int? {
        guard let new = newAmount else { return nil }
        return new - currentCount
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Supply Type Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TYPE OF CLEANING SUPPLY")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Picker("Type", selection: $selectedType) {
                            ForEach(availableSupplies, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                    }
                    
                    // MARK: - Current Count Display
                    VStack(spacing: 8) {
                        Text("CURRENTLY IN STOCK")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.secondary)
                        Text("\(currentCount)")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(.black)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    
                    // MARK: - New Amount Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NEW AMOUNT")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Enter new count", text: $amountText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 48, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.black),
                                alignment: .bottom
                            )
                    }
                    
                    // MARK: - Difference Preview
                    if let diff = difference, diff != 0 {
                        HStack(spacing: 8) {
                            Image(systemName: diff > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundColor(.black)
                            Text(diff > 0 ? "Adding \(diff)" : "Removing \(abs(diff))")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 8)
                    } else if let diff = difference, diff == 0 {
                        Text("No change")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                    
                    // MARK: - Save Button
                    Button(action: saveAdjustment) {
                        Text("SAVE ADJUSTMENT")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                    }
                    .disabled(newAmount == nil || newAmount == currentCount)
                    .opacity(newAmount != nil && newAmount != currentCount ? 1 : 0.3)
                }
                .padding(24)
            }
            .background(Color.white)
            .navigationTitle("Adjust Stock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func saveAdjustment() {
        guard let new = newAmount, new >= 0 else { return }
        store.setStock(new, for: selectedType)
        presentationMode.wrappedValue.dismiss()
    }
}
