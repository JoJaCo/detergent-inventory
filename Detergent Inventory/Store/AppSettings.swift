//
//  AppSettings.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 10/12/26.
//

import Foundation
import Combine

class AppSettings: ObservableObject {
    @Published var companyName: String {
        didSet {
            UserDefaults.standard.set(companyName, forKey: Self.companyNameKey)
        }
    }
    
    private static let companyNameKey = "companyName"
    private static let defaultCompanyName = "Scent Saver"
    
    init() {
        let saved = UserDefaults.standard.string(forKey: Self.companyNameKey)
        self.companyName = saved ?? Self.defaultCompanyName
    }
}
