import Foundation
import Combine

class InventoryStore: ObservableObject {
    @Published var bucketsInStock: Int = 0
    @Published var sales: [Sale] = []
    
    // New: per-supply-type bucket counts
    @Published var inventoryByType: [String: Int] = [:]
    
    private let stockKey = "bucketsInStock"
    private let salesKey = "sales"
    private let inventoryKey = "inventoryByType"
    
    init() {
        load()
    }
    
    // MARK: - Add / Remove
    func addBuckets(_ amount: Int, type: String? = nil) {
        bucketsInStock += amount
        if let type = type, !type.isEmpty {
            inventoryByType[type, default: 0] += amount
        }
        save()
    }
    
    func removeBuckets(_ amount: Int, type: String? = nil) -> Bool {
        guard bucketsInStock >= amount else { return false }
        if let type = type, !type.isEmpty {
            let current = inventoryByType[type, default: 0]
            guard current >= amount else { return false }
            inventoryByType[type] = current - amount
        }
        bucketsInStock -= amount
        save()
        return true
    }
    
    // MARK: - Sales
    func recordSale(clientName: String,
                    quantity: Int,
                    paymentMethod: String,
                    typeOfCleaningSupply: [String],
                    date: Date = Date()) -> Bool {
        guard bucketsInStock >= quantity else { return false }
        bucketsInStock -= quantity
        
        // Reduce per-type counts (split evenly across the selected types)
        if !typeOfCleaningSupply.isEmpty {
            let perType = quantity / typeOfCleaningSupply.count
            let remainder = quantity % typeOfCleaningSupply.count
            for (index, type) in typeOfCleaningSupply.enumerated() {
                let deduct = perType + (index < remainder ? 1 : 0)
                let current = inventoryByType[type, default: 0]
                inventoryByType[type] = max(0, current - deduct)
            }
        }
        
        let sale = Sale(
            clientName: clientName,
            date: date,
            quantity: quantity,
            paymentMethod: paymentMethod,
            typeOfCleaningSupply: typeOfCleaningSupply
        )
        sales.append(sale)
        save()
        return true
    }
    
    // MARK: - Persistence
    private func save() {
        UserDefaults.standard.set(bucketsInStock, forKey: stockKey)
        if let encoded = try? JSONEncoder().encode(sales) {
            UserDefaults.standard.set(encoded, forKey: salesKey)
        }
        if let encodedInv = try? JSONEncoder().encode(inventoryByType) {
            UserDefaults.standard.set(encodedInv, forKey: inventoryKey)
        }
    }
    
    private func load() {
        bucketsInStock = UserDefaults.standard.integer(forKey: stockKey)
        if let data = UserDefaults.standard.data(forKey: salesKey),
           let decoded = try? JSONDecoder().decode([Sale].self, from: data) {
            sales = decoded
        }
        if let invData = UserDefaults.standard.data(forKey: inventoryKey),
           let decodedInv = try? JSONDecoder().decode([String: Int].self, from: invData) {
            inventoryByType = decodedInv
        }
    }
}
