import SwiftUI

struct SaleRow: View {
    let sale: Sale
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(sale.clientName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text(sale.paymentMethod.uppercased())
                    .font(.caption2).tracking(1).foregroundColor(.secondary)
                
                if !sale.typeOfCleaningSupply.isEmpty {
                    Text(sale.typeOfCleaningSupply.joined(separator: " • "))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(sale.quantity) bucket\(sale.quantity == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                Text(sale.date, style: .date)
                    .font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}
