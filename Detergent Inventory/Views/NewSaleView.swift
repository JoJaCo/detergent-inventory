import SwiftUI

enum ActiveSheet: Identifiable {
    case saleComplete(Sale)
    case shareInvoice(URL)
    
    var id: String {
        switch self {
        case .saleComplete(let sale): return "complete-\(sale.id)"
        case .shareInvoice(let url): return "share-\(url.absoluteString)"
        }
    }
}

struct NewSaleView: View {
    @EnvironmentObject var store: InventoryStore
    @EnvironmentObject var settings: AppSettings          // ← NEW
    @Environment(\.presentationMode) var presentationMode
    
    // Client info
    @State private var clientName: String = ""
    @State private var clientAddress: String = ""
    
    // Sale details
    @State private var paymentMethod: String = "Cash"
    @State private var saleDate: Date = Date()
    
    // Line items (drafts)
    @State private var draftItems: [DraftLineItem] = []
    
    // Error
    @State private var showError = false
    @State private var errorMessage: String = ""
    
    // Post-sale
    @State private var activeSheet: ActiveSheet?
    @State private var isGeneratingInvoice = false
    
    let paymentMethods = ["Cash", "Card", "Transfer", "Check"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    
                    // MARK: - Client Info
                    sectionHeader("CLIENT")
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NAME")
                            .font(.caption).tracking(2).foregroundColor(.secondary)
                        TextField("Client name", text: $clientName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle().frame(height: 2).foregroundColor(.black),
                                alignment: .bottom
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ADDRESS")
                            .font(.caption).tracking(2).foregroundColor(.secondary)
                        TextField("Street, city, state", text: $clientAddress)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle().frame(height: 2).foregroundColor(.black),
                                alignment: .bottom
                            )
                    }
                    
                    // MARK: - Date & Payment
                    sectionHeader("DETAILS")
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DATE")
                            .font(.caption).tracking(2).foregroundColor(.secondary)
                        DatePicker("", selection: $saleDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .accentColor(.black)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PAYMENT METHOD")
                            .font(.caption).tracking(2).foregroundColor(.secondary)
                        Picker("Payment Method", selection: $paymentMethod) {
                            ForEach(paymentMethods, id: \.self) { method in
                                Text(method).tag(method)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .accentColor(.black)
                    }
                    
                    // MARK: - Line Items
                    sectionHeader("ITEMS")
                    
                    if draftItems.isEmpty {
                        VStack(spacing: 12) {
                            Text("No items yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Tap below to add a product.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        VStack(spacing: 0) {
                            ForEach($draftItems) { $item in
                                DraftLineItemRow(item: $item) {
                                    draftItems.removeAll { $0.id == item.id }
                                }
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.black.opacity(0.15))
                            }
                        }
                    }
                    
                    Button(action: addDraftItem) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("ADD ITEM")
                                .font(.system(size: 14, weight: .semibold))
                                .tracking(1)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            Rectangle().stroke(Color.black, lineWidth: 2)
                        )
                    }
                    .disabled(store.products.isEmpty)
                    .opacity(store.products.isEmpty ? 0.3 : 1)
                    
                    if store.products.isEmpty {
                        Text("Add products before creating a sale.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // MARK: - Total
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.black)
                        .padding(.top, 8)
                    
                    HStack {
                        Text("TOTAL")
                            .font(.system(size: 16, weight: .bold))
                            .tracking(2)
                        Spacer()
                        Text("$\(String(format: "%.2f", computedTotal))")
                            .font(.system(size: 28, weight: .bold))
                            .monospacedDigit()
                    }
                    .padding(.top, 8)
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    // MARK: - Record
                    Button(action: recordSale) {
                        Text("RECORD SALE")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                    }
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.3)
                }
                .padding(24)
            }
            .background(Color.white)
            .navigationTitle("New Sale")
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
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .saleComplete(let sale):
                SaleCompleteView(
                    sale: sale,
                    onShareInvoice: { shareInvoice(for: sale) },
                    onDone: { presentationMode.wrappedValue.dismiss() }
                )
            case .shareInvoice(let url):
                ShareSheet(items: [url])
            }
        }
        .overlay {
            if isGeneratingInvoice {
                invoiceLoadingOverlay
            }
        }
    }
    
    // MARK: - Invoice Loading Overlay
    
    private var invoiceLoadingOverlay: some View {
        ZStack {
            Color.white.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.5)
                Text("GENERATING INVOICE")
                    .font(.caption).tracking(2).foregroundColor(.black)
            }
            .padding(40)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 2))
        }
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(_ text: String) -> some View {
        HStack {
            Text(text).font(.caption).tracking(2).foregroundColor(.secondary)
            Spacer()
        }
        .padding(.bottom, -12)
    }
    
    private var computedTotal: Double {
        draftItems.reduce(0) { $0 + $1.subtotal }
    }
    
    private var isFormValid: Bool {
        !clientName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftItems.isEmpty &&
        draftItems.allSatisfy { $0.isValid }
    }
    
    private func addDraftItem() {
        guard let firstProduct = store.products.first else { return }
        draftItems.append(DraftLineItem(
            productId: firstProduct.id,
            productName: firstProduct.name,
            quantity: 1,
            pricePerUnit: firstProduct.pricePerUnit
        ))
    }
    
    private func recordSale() {
        let items: [LineItem] = draftItems.compactMap { draft in
            guard draft.quantity > 0 else { return nil }
            return LineItem(
                productId: draft.productId,
                productName: draft.productName,
                quantity: draft.quantity,
                pricePerUnit: draft.pricePerUnit
            )
        }
        
        guard !items.isEmpty else {
            showError = true
            errorMessage = "Add at least one item."
            return
        }
        
        let success = store.recordSale(
            clientName: clientName.trimmingCharacters(in: .whitespaces),
            clientAddress: clientAddress.trimmingCharacters(in: .whitespaces),
            paymentMethod: paymentMethod,
            lineItems: items,
            date: saleDate
        )
        
        if success {
            if let newest = store.sales.last {
                activeSheet = .saleComplete(newest)
            }
        } else {
            showError = true
            errorMessage = "One or more items exceed available stock."
        }
    }
    
    private func shareInvoice(for sale: Sale) {
        isGeneratingInvoice = true
        
        // Capture company name on main thread before dispatching
        let companyName = settings.companyName
        
        // Generate off the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            let url = InvoiceGenerator.makePDF(for: sale, companyName: companyName)  // ← NEW
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isGeneratingInvoice = false
                    if let url = url {
                        activeSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            activeSheet = .shareInvoice(url)
                        }
                    } else {
                        showError = true
                        errorMessage = "Could not generate invoice."
                    }
                }
            }
        }
    }
}

// MARK: - Sale Complete View

struct SaleCompleteView: View {
    let sale: Sale
    let onShareInvoice: () -> Void
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.black, lineWidth: 3)
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text("SALE RECORDED")
                .font(.system(size: 18, weight: .bold))
                .tracking(2)
                .foregroundColor(.black)
            
            VStack(spacing: 8) {
                Text(sale.clientName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                Text("$\(String(format: "%.2f", sale.total))")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.black)
                    .monospacedDigit()
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: onShareInvoice) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("SHARE INVOICE")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                }
                
                Button(action: onDone) {
                    Text("DONE")
                        .font(.system(size: 16, weight: .semibold))
                        .tracking(1)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(
                            Rectangle().stroke(Color.black, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.white)
        .interactiveDismissDisabled()
    }
}

// MARK: - Draft Line Item

struct DraftLineItem: Identifiable, Equatable {
    let id: UUID
    var productId: UUID
    var productName: String
    var quantity: Int
    var pricePerUnit: Double
    
    var subtotal: Double {
        Double(quantity) * pricePerUnit
    }
    
    var isValid: Bool {
        quantity > 0
    }
    
    init(productId: UUID, productName: String, quantity: Int, pricePerUnit: Double) {
        self.id = UUID()
        self.productId = productId
        self.productName = productName
        self.quantity = quantity
        self.pricePerUnit = pricePerUnit
    }
}

// MARK: - Draft Line Item Row

struct DraftLineItemRow: View {
    @EnvironmentObject var store: InventoryStore
    @Binding var item: DraftLineItem
    let onDelete: () -> Void
    
    @State private var quantityText: String = ""
    @State private var priceText: String = ""
    
    private var maxStock: Int {
        store.products.first(where: { $0.id == item.productId })?.stock ?? 0
    }
    
    private var exceedsStock: Bool {
        item.quantity > maxStock
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Menu {
                    ForEach(store.products) { product in
                        Button {
                            selectProduct(product)
                        } label: {
                            Text("\(product.name) · \(product.stock) in stock")
                        }
                    }
                } label: {
                    HStack {
                        Text(item.productName.isEmpty ? "Select product" : item.productName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black.opacity(0.5))
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("QTY").font(.caption2).tracking(1).foregroundColor(.secondary)
                    TextField("0", text: $quantityText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.vertical, 6)
                        .overlay(
                            Rectangle().frame(height: 1.5).foregroundColor(.black),
                            alignment: .bottom
                        )
                        .onChange(of: quantityText) { newValue in
                            item.quantity = Int(newValue) ?? 0
                        }
                }
                .frame(width: 70)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("PRICE").font(.caption2).tracking(1).foregroundColor(.secondary)
                    HStack(spacing: 2) {
                        Text("$").font(.system(size: 16, weight: .medium)).foregroundColor(.black)
                        TextField("0.00", text: $priceText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .onChange(of: priceText) { newValue in
                                item.pricePerUnit = Double(newValue) ?? 0
                            }
                    }
                    .padding(.vertical, 6)
                    .overlay(
                        Rectangle().frame(height: 1.5).foregroundColor(.black),
                        alignment: .bottom
                    )
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("SUBTOTAL").font(.caption2).tracking(1).foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", item.subtotal))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .monospacedDigit()
                }
            }
            
            if exceedsStock {
                Text("Only \(maxStock) in stock")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 12)
        .onAppear {
            quantityText = item.quantity > 0 ? "\(item.quantity)" : ""
            priceText = item.pricePerUnit > 0 ? String(format: "%.2f", item.pricePerUnit) : ""
        }
    }
    
    private func selectProduct(_ product: Product) {
        item.productId = product.id
        item.productName = product.name
        item.pricePerUnit = product.pricePerUnit
        priceText = String(format: "%.2f", product.pricePerUnit)
    }
}

struct NewSaleView_Previews: PreviewProvider {
    static var previews: some View {
        NewSaleView()
            .environmentObject(InventoryStore())
            .environmentObject(AppSettings())
    }
}
