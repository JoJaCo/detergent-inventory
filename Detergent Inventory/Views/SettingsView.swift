//
//  SettingsView.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 10/12/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var draftCompanyName: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    
                    sectionHeader("INVOICE")
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("COMPANY NAME")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.secondary)
                        TextField("Scent Saver", text: $draftCompanyName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle().frame(height: 2).foregroundColor(.black),
                                alignment: .bottom
                            )
                            .focused($isFocused)
                    }
                    
                    Text("This name appears at the top of every invoice you generate.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: save) {
                        Text("SAVE")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                    }
                    .disabled(draftCompanyName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(draftCompanyName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.3 : 1)
                    
                    // Reset option
                    Button(action: resetToDefault) {
                        Text("RESET TO DEFAULT")
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(
                                Rectangle().stroke(Color.black, lineWidth: 2)
                            )
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .background(Color.white)
        }
        .background(Color.white)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            draftCompanyName = settings.companyName
        }
    }
    
    private func sectionHeader(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.caption)
                .tracking(2)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.bottom, -12)
    }
    
    private func save() {
        let trimmed = draftCompanyName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        settings.companyName = trimmed
        presentationMode.wrappedValue.dismiss()
    }
    
    private func resetToDefault() {
        draftCompanyName = "Scent Saver"
        settings.companyName = "Scent Saver"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(AppSettings())
        }
    }
}
