//
//  UIApplication.swift
//  SwiftfulCrypto
//
//  Created by Magd on 25/10/2026.
//

import Foundation
import SwiftUI

extension UIApplication {
    
    func endEditing(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
