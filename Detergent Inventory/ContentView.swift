//
//  ContentView.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 9/21/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: InventoryStore
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Stock Display
                stockHeader
                
                // MARK: - Actions
                VStack(spacing: 0) {
                    navRow(title: "NEW SALE", icon: "dollarsign.circle") {
                        NewSaleView()
                    }
                    divider
                    
                    navRow(title: "PRODUCTS", icon: "shippingbox") {
                        ProductListView()
                    }
                    divider
                    
                    navRow(title: "VIEW INVENTORY", icon: "list.bullet.rectangle") {
                        InventoryView()
                    }
                    divider
                    
                    navRow(title: "SALES HISTORY", icon: "doc.text") {
                        SalesHistoryView()
                    }
                }
                .background(Color.white)
                
                Spacer()
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
    }
    
    // MARK: - Stock Header
    
    private var stockHeader: some View {
        VStack(spacing: 8) {
            Text("BUCKETS IN STOCK")
                .font(.caption)
                .tracking(2)
                .foregroundColor(.secondary)
            
            if store.totalStock == 0 {
                Text("NO INVENTORY")
                    .font(.system(size: 32, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.black)
                    .padding(.vertical, 20)
            } else {
                Text("\(store.totalStock)")
                    .font(.system(size: 72, weight: .bold, design: .default))
                    .foregroundColor(.black)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black),
            alignment: .bottom
        )
    }
    
    // MARK: - Helpers
    
    private var divider: some View {
        Rectangle().frame(height: 1).foregroundColor(.black)
    }
    
    private func navRow<Destination: View>(
        title: String,
        icon: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination().environmentObject(store)) {
            HStack {
                Image(systemName: icon).font(.system(size: 20, weight: .medium))
                Text(title).font(.system(size: 16, weight: .semibold)).tracking(1)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.black)
            .padding(.horizontal)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(InventoryStore())
    }
}
