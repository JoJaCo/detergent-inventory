//
//  AddEditProductView.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 10/10/26.
//

import SwiftUI

struct AddEditProductView: View {
    enum Mode {
        case add
        case edit(Product)
    }
    
    @EnvironmentObject var store: InventoryStore
    @Environment(\.presentationMode) var presentationMode
    
    let mode: Mode
    
    @State private var name: String = ""
    @State private var stockText: String = ""
    @State private var priceText: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    private var title: String {
        isEditing ? "Edit Product" : "New Product"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    
                    // MARK: - Product Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PRODUCT NAME")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.secondary)
                        TextField("e.g. Lavender Detergent", text: $name)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.black),
                                alignment: .bottom
                            )
                    }
                    
                    // MARK: - Stock
                    VStack(alignment: .leading, spacing: 6) {
                        Text("AMOUNT IN STOCK")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.secondary)
                        TextField("0", text: $stockText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.black),
                                alignment: .bottom
                            )
                    }
                    
                    // MARK: - Price
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PRICE PER UNIT")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Text("$")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                            TextField("0.00", text: $priceText)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 8)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.black),
                            alignment: .bottom
                        )
                    }
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    // MARK: - Save Button
                    Button(action: save) {
                        Text(isEditing ? "SAVE CHANGES" : "ADD PRODUCT")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                    }
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.3)
                    
                    // MARK: - Delete Button (only in edit mode)
                    if isEditing {
                        Button(action: deleteProduct) {
                            Text("DELETE PRODUCT")
                                .font(.system(size: 14, weight: .semibold))
                                .tracking(1)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding(24)
            }
            .background(Color.white)
            .navigationTitle(title)
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
        .onAppear {
            loadExistingValues()
        }
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(stockText) != nil &&
        Double(priceText) != nil
    }
    
    // MARK: - Load Existing Values (edit mode)
    
    private func loadExistingValues() {
        guard case .edit(let product) = mode else { return }
        name = product.name
        stockText = "\(product.stock)"
        priceText = String(format: "%.2f", product.pricePerUnit)
    }
    
    // MARK: - Save
    
    private func save() {
        guard let stock = Int(stockText), stock >= 0,
              let price = Double(priceText), price >= 0 else {
            showError = true
            errorMessage = "Please enter valid numbers."
            return
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            showError = true
            errorMessage = "Please enter a product name."
            return
        }
        
        switch mode {
        case .add:
            store.addProduct(name: trimmedName, stock: stock, pricePerUnit: price)
        case .edit(let product):
            var updated = product
            updated.name = trimmedName
            updated.stock = stock
            updated.pricePerUnit = price
            store.updateProduct(updated)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: - Delete
    
    private func deleteProduct() {
        guard case .edit(let product) = mode else { return }
        store.deleteProduct(product)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddEditProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditProductView(mode: .add)
            .environmentObject(InventoryStore())
    }
}
