import Foundation

struct Sale: Identifiable, Codable {
    let id: UUID
    let clientName: String
    let date: Date
    let quantity: Int
    let paymentMethod: String
    let typeOfCleaningSupply: [String]
    
    init(clientName: String,
         date: Date,
         quantity: Int,
         paymentMethod: String,
         typeOfCleaningSupply: [String] = []) {
        self.id = UUID()
        self.clientName = clientName
        self.date = date
        self.quantity = quantity
        self.paymentMethod = paymentMethod
        self.typeOfCleaningSupply = typeOfCleaningSupply
    }
    
    // Custom decoder so old saved sales (without the new field) still load
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        clientName = try container.decode(String.self, forKey: .clientName)
        date = try container.decode(Date.self, forKey: .date)
        quantity = try container.decode(Int.self, forKey: .quantity)
        paymentMethod = try container.decode(String.self, forKey: .paymentMethod)
        typeOfCleaningSupply = (try? container.decode([String].self, forKey: .typeOfCleaningSupply)) ?? []
    }
}
