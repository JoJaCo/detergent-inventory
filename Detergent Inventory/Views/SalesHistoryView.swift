import SwiftUI

struct SalesHistoryView: View {
    @EnvironmentObject var store: InventoryStore
    
    @State private var showingClearConfirmation = false
    @State private var shareItem: ShareItem?
    @State private var exportError: String?
    @State private var isExporting = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if store.sales.isEmpty {
                    emptyState
                } else {
                    historyList
                    actionBar
                }
            }
            .background(Color.white)
            
            // MARK: - Loading Overlay
            if isExporting {
                loadingOverlay
            }
        }
        .background(Color.white)
        .navigationTitle("Sales History")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Clear all sales history?",
            isPresented: $showingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear History", role: .destructive) {
                store.clearSalesHistory()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete \(store.sales.count) sale\(store.sales.count == 1 ? "" : "s"). This cannot be undone.")
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.url])
        }
        .alert("Export Failed", isPresented: .constant(exportError != nil)) {
            Button("OK") { exportError = nil }
        } message: {
            Text(exportError ?? "")
        }
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            // Dimmed backdrop
            Color.white.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.5)
                
                Text("PREPARING EXPORT")
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.black)
                
                Text("This may take a moment.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(40)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .transition(.opacity)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.secondary)
            Text("NO SALES YET")
                .font(.caption)
                .tracking(2)
                .foregroundColor(.secondary)
            Text("Record a sale to see it here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - History List
    
    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.sales.reversed()) { sale in
                    SaleRow(sale: sale)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.black.opacity(0.15))
                }
            }
        }
    }
    
    // MARK: - Action Bar
    
    private var actionBar: some View {
        HStack(spacing: 0) {
            Button(action: exportCSV) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("EXPORT CSV")
                        .font(.system(size: 14, weight: .semibold))
                        .tracking(1)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isExporting)
            
            Rectangle()
                .frame(width: 1)
                .foregroundColor(.black)
            
            Button(action: { showingClearConfirmation = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("CLEAR")
                        .font(.system(size: 14, weight: .semibold))
                        .tracking(1)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isExporting)
        }
        .background(Color.white)
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(.black),
            alignment: .top
        )
    }
    
    // MARK: - Export
    
    private func exportCSV() {
        guard !isExporting else { return }
        
        withAnimation(.easeIn(duration: 0.15)) {
            isExporting = true
        }
        
        // Snapshot the CSV string on the main thread (fast)
        let csv = store.salesCSV()
        guard !csv.isEmpty else {
            isExporting = false
            return
        }
        
        let fileName = "detergent-sales-\(dateStamp()).csv"
        
        // Write the file on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try csv.write(to: tempURL, atomically: true, encoding: .utf8)
                
                DispatchQueue.main.async {
                    // Short delay so the overlay is visible even if the write is instant.
                    // Without this, the overlay would flash for a few milliseconds and feel glitchy.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isExporting = false
                        shareItem = ShareItem(url: tempURL)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isExporting = false
                    exportError = "Could not create export file: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func dateStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// MARK: - Share Item Wrapper

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Sales History
struct SalesHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SalesHistoryView()
                .environmentObject(InventoryStore())
        }
    }
}
