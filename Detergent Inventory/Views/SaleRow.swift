//
//  SaleRow.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 10/10/26.
//

import SwiftUI

struct SaleRow: View {
    let sale: Sale
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top row: client + total
            HStack(alignment: .firstTextBaseline) {
                Text(sale.clientName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Text("$\(String(format: "%.2f", sale.total))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .monospacedDigit()
            }
            
            // Address (if present)
            if !sale.clientAddress.isEmpty {
                Text(sale.clientAddress)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Date + payment + item count
            HStack(spacing: 8) {
                Text(sale.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("·")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(sale.paymentMethod.uppercased())
                    .font(.caption2).tracking(1)
                    .foregroundColor(.secondary)
                Text("·")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(sale.totalQuantity) item\(sale.totalQuantity == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Line item summary
            if !sale.lineItems.isEmpty {
                Text(itemSummary)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    /// "Lavender Detergent ×5, Bleach ×2"
    private var itemSummary: String {
        sale.lineItems
            .map { "\($0.productName) ×\($0.quantity)" }
            .joined(separator: ", ")
    }
}

struct SaleRow_Previews: PreviewProvider {
    static var previews: some View {
        SaleRow(sale: Sale(
            clientName: "John Doe",
            clientAddress: "123 Main St",
            paymentMethod: "Cash",
            lineItems: [
                LineItem(productId: UUID(), productName: "Lavender Detergent", quantity: 5, pricePerUnit: 12.00),
                LineItem(productId: UUID(), productName: "Bleach", quantity: 2, pricePerUnit: 8.00)
            ]
        ))
        .previewLayout(.sizeThatFits)
    }
}
