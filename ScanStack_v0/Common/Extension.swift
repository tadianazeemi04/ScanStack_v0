//
//  Extension.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 29/06/2026.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        // Strip out any hash symbols or extra spaces
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHexCode).scanHexInt64(&rgbValue)
        
        let redValue = Double((rgbValue >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
}
