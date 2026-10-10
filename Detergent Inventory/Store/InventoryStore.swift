import Foundation
import Combine

class InventoryStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var sales: [Sale] = []
    
    private let productsKey = "products"
    private let salesKey = "sales"
    
    init() {
        load()
    }
    
    // MARK: - Computed totals
    
    /// Total stock across all products
    var totalStock: Int {
        products.reduce(0) { $0 + $1.stock }
    }
    
    // MARK: - Products
    
    func addProduct(name: String, stock: Int, pricePerUnit: Double) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              stock >= 0,
              pricePerUnit >= 0 else { return }
        let product = Product(name: name, stock: stock, pricePerUnit: pricePerUnit)
        products.append(product)
        save()
    }
    
    func updateProduct(_ product: Product) {
        guard let index = products.firstIndex(where: { $0.id == product.id }) else { return }
        products[index] = product
        save()
    }
    
    func deleteProduct(_ product: Product) {
        products.removeAll { $0.id == product.id }
        save()
    }
    
    /// Directly set a product's stock to a new value.
    func setStock(_ newStock: Int, for productId: UUID) {
        guard newStock >= 0,
              let index = products.firstIndex(where: { $0.id == productId }) else { return }
        products[index].stock = newStock
        save()
    }
    
    // MARK: - Sales
    
    /// Records a sale and deducts the sold quantities from each product's stock.
    /// Returns false if any line item exceeds available stock.
    func recordSale(clientName: String,
                    clientAddress: String,
                    paymentMethod: String,
                    lineItems: [LineItem],
                    date: Date = Date()) -> Bool {
        guard !clientName.trimmingCharacters(in: .whitespaces).isEmpty,
              !lineItems.isEmpty else { return false }
        
        // Validate stock for every line item
        for item in lineItems {
            guard let product = products.first(where: { $0.id == item.productId }),
                  product.stock >= item.quantity else {
                return false
            }
        }
        
        // Deduct stock
        for item in lineItems {
            guard let index = products.firstIndex(where: { $0.id == item.productId }) else { continue }
            products[index].stock -= item.quantity
        }
        
        // Append the sale
        let sale = Sale(
            clientName: clientName,
            clientAddress: clientAddress,
            date: date,
            paymentMethod: paymentMethod,
            lineItems: lineItems
        )
        sales.append(sale)
        save()
        return true
    }
    
    // MARK: - Sales History Management
    
    /// Removes all sales records. Does NOT restore inventory — those buckets are gone.
    func clearSalesHistory() {
        sales = []
        save()
    }
    
    /// Builds a CSV string from all sales. Returns an empty string if there are no sales.
    func salesCSV() -> String {
        guard !sales.isEmpty else { return "" }
        
        // Header
        var lines: [String] = [
            "Date,Client Name,Client Address,Payment Method,Product,Quantity,Unit Price,Subtotal,Sale Total"
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Sort sales oldest first for a natural ledger order
        let sortedSales = sales.sorted { $0.date < $1.date }
        
        for sale in sortedSales {
            let dateStr = dateFormatter.string(from: sale.date)
            let client = escapeCSV(sale.clientName)
            let address = escapeCSV(sale.clientAddress)
            let method = escapeCSV(sale.paymentMethod)
            let saleTotal = String(format: "%.2f", sale.total)
            
            if sale.lineItems.isEmpty {
                // Edge case: sale with no items (shouldn't happen, but be safe)
                lines.append("\(dateStr),\(client),\(address),\(method),,,,\(saleTotal)")
            } else {
                for item in sale.lineItems {
                    let product = escapeCSV(item.productName)
                    let qty = "\(item.quantity)"
                    let price = String(format: "%.2f", item.pricePerUnit)
                    let subtotal = String(format: "%.2f", item.subtotal)
                    lines.append("\(dateStr),\(client),\(address),\(method),\(product),\(qty),\(price),\(subtotal),\(saleTotal)")
                }
            }
        }
        
        return lines.joined(separator: "\n")
    }
    
    /// Escapes a CSV field: wraps in quotes if it contains a comma, quote, or newline.
    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }
    
    // MARK: - Persistence
    
    private func save() {
        if let encodedProducts = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(encodedProducts, forKey: productsKey)
        }
        if let encodedSales = try? JSONEncoder().encode(sales) {
            UserDefaults.standard.set(encodedSales, forKey: salesKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: productsKey),
           let decoded = try? JSONDecoder().decode([Product].self, from: data) {
            products = decoded
        }
        if let data = UserDefaults.standard.data(forKey: salesKey),
           let decoded = try? JSONDecoder().decode([Sale].self, from: data) {
            sales = decoded
        }
    }
    
    // MARK: - Migration helper
    
    /// Call this ONCE if you have old Sale data in UserDefaults that doesn't
    /// match the new model. Wipes old data.
    func wipeAllData() {
        UserDefaults.standard.removeObject(forKey: "products")
        UserDefaults.standard.removeObject(forKey: "sales")
        UserDefaults.standard.removeObject(forKey: "bucketsInStock")
        UserDefaults.standard.removeObject(forKey: "inventoryByType")
        products = []
        sales = []
    }
}
