import Foundation

struct Sale: Identifiable, Codable {
    let id: UUID
    let clientName: String
    let clientAddress: String
    let date: Date
    let paymentMethod: String
    let lineItems: [LineItem]
    
    /// Computed, not stored. Always equals the sum of line item subtotals.
    var total: Double {
        lineItems.reduce(0) { $0 + $1.subtotal }
    }
    
    /// Total number of buckets in this sale (across all items).
    var totalQuantity: Int {
        lineItems.reduce(0) { $0 + $1.quantity }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, clientName, clientAddress, date, paymentMethod, lineItems
    }
    
    init(clientName: String,
         clientAddress: String,
         date: Date = Date(),
         paymentMethod: String,
         lineItems: [LineItem]) {
        self.id = UUID()
        self.clientName = clientName
        self.clientAddress = clientAddress
        self.date = date
        self.paymentMethod = paymentMethod
        self.lineItems = lineItems
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        clientName = try container.decode(String.self, forKey: .clientName)
        clientAddress = (try? container.decode(String.self, forKey: .clientAddress)) ?? ""
        date = try container.decode(Date.self, forKey: .date)
        paymentMethod = try container.decode(String.self, forKey: .paymentMethod)
        lineItems = (try? container.decode([LineItem].self, forKey: .lineItems)) ?? []
    }
}
