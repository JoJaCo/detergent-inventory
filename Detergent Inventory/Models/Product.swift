//
//  Product.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 10/10/26.
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var stock: Int
    var pricePerUnit: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, stock, pricePerUnit
    }
    
    init(name: String, stock: Int = 0, pricePerUnit: Double = 0) {
        self.id = UUID()
        self.name = name
        self.stock = stock
        self.pricePerUnit = pricePerUnit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        stock = (try? container.decode(Int.self, forKey: .stock)) ?? 0
        pricePerUnit = (try? container.decode(Double.self, forKey: .pricePerUnit)) ?? 0
    }
}
