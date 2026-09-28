//
//  ContentView.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 9/21/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: InventoryStore
    @State private var showingAddStock = false
    @State private var showingSell = false
    @State private var showingRemoveStock = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Stock Display
                VStack(spacing: 8) {
                    Text("BUCKETS IN STOCK")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.secondary)
                    Text("\(store.bucketsInStock)")
                        .font(.system(size: 72, weight: .bold, design: .default))
                        .foregroundColor(.black)
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
                
                // MARK: - Actions
                VStack(spacing: 0) {
                    actionButton(title: "ADD BUCKETS", icon: "plus") {
                        showingAddStock = true
                    }
                    divider
                    
                    actionButton(title: "REMOVE BUCKETS", icon: "minus") {
                        showingRemoveStock = true
                    }
                    divider
                    
                    // View Inventory (navigates to InventoryView)
                    NavigationLink(destination: InventoryView().environmentObject(store)) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 20, weight: .medium))
                            Text("VIEW INVENTORY")
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(1)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 18)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    divider
                    
                    actionButton(title: "SELL", icon: "dollarsign.circle") {
                        showingSell = true
                    }
                }
                .background(Color.white)
                
                // MARK: - Sales History
                if !store.sales.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SALES HISTORY")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(store.sales.reversed()) { sale in
                                    SaleRow(sale: sale)
                                    divider
                                }
                            }
                        }
                    }
                    .background(Color.white)
                } else {
                    Spacer()
                    Text("No sales recorded yet.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Spacer()
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingAddStock) {
            AddStockView().environmentObject(store)
        }
        .sheet(isPresented: $showingSell) {
            SellView().environmentObject(store)
        }
        .sheet(isPresented: $showingRemoveStock) {
            RemoveStockView().environmentObject(store)
        }
    }
    
    // MARK: - Helpers
    private var divider: some View {
        Rectangle().frame(height: 1).foregroundColor(.black)
    }
    
    private func actionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
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
