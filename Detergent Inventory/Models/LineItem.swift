//
//  LineItem.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 10/10/26.
//

import Foundation

struct LineItem: Identifiable, Codable, Hashable {
    let id: UUID
    let productId: UUID
    let productName: String       // snapshot: name at the time of sale
    let quantity: Int
    let pricePerUnit: Double      // snapshot: price at the time of sale
    
    var subtotal: Double {
        Double(quantity) * pricePerUnit
    }
    
    enum CodingKeys: String, CodingKey {
        case id, productId, productName, quantity, pricePerUnit
    }
    
    init(productId: UUID, productName: String, quantity: Int, pricePerUnit: Double) {
        self.id = UUID()
        self.productId = productId
        self.productName = productName
        self.quantity = quantity
        self.pricePerUnit = pricePerUnit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        productId = try container.decode(UUID.self, forKey: .productId)
        productName = try container.decode(String.self, forKey: .productName)
        quantity = try container.decode(Int.self, forKey: .quantity)
        pricePerUnit = try container.decode(Double.self, forKey: .pricePerUnit)
    }
}
