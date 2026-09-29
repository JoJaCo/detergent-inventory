import Foundation
import Combine

class InventoryStore: ObservableObject {
    @Published var bucketsInStock: Int = 0
    @Published var sales: [Sale] = []
    @Published var inventoryByType: [String: Int] = [:]
    
    private let stockKey = "bucketsInStock"
    private let salesKey = "sales"
    private let inventoryKey = "inventoryByType"
    
    init() {
        load()
        reconcileInventory()
    }
    
    // MARK: - Set Stock (new core operation)
    /// Sets the exact count for a supply type, and updates the grand total to match.
    /// This is the only way inventory should change outside of a sale.
    func setStock(_ newAmount: Int, for type: String) {
        guard !type.isEmpty, newAmount >= 0 else { return }
        let oldAmount = inventoryByType[type, default: 0]
        let diff = newAmount - oldAmount
        inventoryByType[type] = newAmount
        bucketsInStock += diff
        if bucketsInStock < 0 { bucketsInStock = 0 }
        save()
    }
    
    // MARK: - Sales
    func recordSale(clientName: String,
                    quantity: Int,
                    paymentMethod: String,
                    typeOfCleaningSupply: [String],
                    date: Date = Date()) -> Bool {
        guard bucketsInStock >= quantity else { return false }
        bucketsInStock -= quantity
        
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
    
    // MARK: - Reconciliation
    private func reconcileInventory() {
        let typeSum = inventoryByType.values.reduce(0, +)
        if typeSum == bucketsInStock { return }
        
        if typeSum < bucketsInStock {
            let leftover = bucketsInStock - typeSum
            inventoryByType["Unsorted", default: 0] += leftover
        } else {
            bucketsInStock = typeSum
        }
        save()
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
