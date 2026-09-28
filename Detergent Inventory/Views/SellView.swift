import SwiftUI

struct SellView: View {
    @EnvironmentObject var store: InventoryStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var clientName = ""
    @State private var quantityText = ""
    @State private var paymentMethod = "Cash"
    @State private var saleDate = Date()
    @State private var showError = false
    
    // Available cleaning supply types
    let availableSupplies = [
        "Laundry Detergent",
        "Dish Soap",
        "Bleach",
        "Fabric Softener",
        "All-Purpose Cleaner",
        "Glass Cleaner",
        "Floor Cleaner",
        "Disinfectant"
    ]
    
    @State private var selectedSupplies: Set<String> = []
    
    let paymentMethods = ["Cash", "Card", "Transfer", "Check"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Client Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CLIENT NAME")
                            .font(.caption).tracking(2).foregroundColor(.secondary)
                        TextField("Enter name", text: $clientName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle().frame(height: 2).foregroundColor(.black),
                                alignment: .bottom
                            )
                    }
                    
                    // Quantity
                    VStack(alignment: .leading, spacing: 6) {
                        Text("QUANTITY (BUCKETS)")
                            .font(.caption).tracking(2).foregroundColor(.secondary)
                        TextField("0", text: $quantityText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle().frame(height: 2).foregroundColor(.black),
                                alignment: .bottom
                            )
                    }
                    
                    // Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DATE")
                            .font(.caption).tracking(2).foregroundColor(.secondary)
                        DatePicker("", selection: $saleDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .accentColor(.black)
                    }
                    
                    // Payment Method
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PAYMENT METHOD")
                            .font(.caption).tracking(2).foregroundColor(.secondary)
                        Picker("Payment Method", selection: $paymentMethod) {
                            ForEach(paymentMethods, id: \.self) { method in
                                Text(method).tag(method)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .accentColor(.black)
                    }
                    
                    // Type of Cleaning Supply (multi-select)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TYPE OF CLEANING SUPPLY")
                            .font(.caption).tracking(2).foregroundColor(.secondary)
                        
                        VStack(spacing: 0) {
                            ForEach(availableSupplies, id: \.self) { supply in
                                Button {
                                    toggleSupply(supply)
                                } label: {
                                    HStack {
                                        Image(systemName: selectedSupplies.contains(supply)
                                              ? "checkmark.square.fill"
                                              : "square")
                                            .font(.system(size: 18))
                                            .foregroundColor(.black)
                                        Text(supply)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 4)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if supply != availableSupplies.last {
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.black.opacity(0.15))
                                }
                            }
                        }
                        .overlay(
                            Rectangle().frame(height: 2).foregroundColor(.black),
                            alignment: .bottom
                        )
                    }
                    
                    if showError {
                        Text("Not enough buckets in stock or invalid quantity.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: recordSale) {
                        Text("RECORD SALE")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                    }
                    .disabled(clientName.isEmpty || (Int(quantityText) ?? 0) <= 0)
                    .opacity(clientName.isEmpty || (Int(quantityText) ?? 0) <= 0 ? 0.3 : 1)
                }
                .padding(24)
            }
            .background(Color.white)
            .navigationTitle("Sell")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.black)
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func toggleSupply(_ supply: String) {
        if selectedSupplies.contains(supply) {
            selectedSupplies.remove(supply)
        } else {
            selectedSupplies.insert(supply)
        }
    }
    
    private func recordSale() {
        guard let quantity = Int(quantityText), quantity > 0, !clientName.isEmpty else {
            showError = true
            return
        }
        let success = store.recordSale(
            clientName: clientName,
            quantity: quantity,
            paymentMethod: paymentMethod,
            typeOfCleaningSupply: Array(selectedSupplies).sorted(),
            date: saleDate
        )
        if success {
            presentationMode.wrappedValue.dismiss()
        } else {
            showError = true
        }
    }
}
