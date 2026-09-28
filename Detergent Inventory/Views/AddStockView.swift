import SwiftUI

struct AddStockView: View {
    @EnvironmentObject var store: InventoryStore
    @Environment(\.presentationMode) var presentationMode
    @State private var amountText = ""
    @State private var selectedType: String = "Laundry Detergent"
    
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How many buckets are you adding?")
                    .font(.headline).foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                
                TextField("0", text: $amountText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 48, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        Rectangle().frame(height: 2).foregroundColor(.black),
                        alignment: .bottom
                    )
                    .padding(.horizontal, 40)
                
                // Supply type picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("TYPE OF CLEANING SUPPLY")
                        .font(.caption).tracking(2).foregroundColor(.secondary)
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
                        Rectangle().frame(height: 2).foregroundColor(.black),
                        alignment: .bottom
                    )
                }
                .padding(.horizontal, 40)
                
                Button(action: addStock) {
                    Text("ADD TO STOCK")
                        .font(.system(size: 16, weight: .semibold))
                        .tracking(1)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                }
                .disabled(Int(amountText) ?? 0 <= 0)
                .opacity((Int(amountText) ?? 0) > 0 ? 1 : 0.3)
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .background(Color.white)
            .navigationTitle("Add Buckets")
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
    
    private func addStock() {
        if let amount = Int(amountText), amount > 0 {
            store.addBuckets(amount, type: selectedType)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
