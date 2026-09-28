import SwiftUI

struct RemoveStockView: View {
    @EnvironmentObject var store: InventoryStore
    @Environment(\.presentationMode) var presentationMode
    @State private var amountText = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How many buckets are you removing?")
                    .font(.headline)
                    .foregroundColor(.black)
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
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.black),
                        alignment: .bottom
                    )
                    .padding(.horizontal, 40)
                
                if showError {
                    Text("Not enough buckets in stock.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Button(action: removeStock) {
                    Text("REMOVE FROM STOCK")
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
            .navigationTitle("Remove Buckets")
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
    
    private func removeStock() {
        if let amount = Int(amountText), amount > 0 {
            let success = store.removeBuckets(amount)
            if success {
                presentationMode.wrappedValue.dismiss()
            } else {
                showError = true
            }
        }
    }
}
