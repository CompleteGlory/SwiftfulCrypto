//
//  HapticManager.swift
//  SwiftfulCrypto
//
//  Created by Magd on 30/10/2026.
//

import Foundation
import SwiftUI

class HapticManager{
    static private let  generator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType){
        generator.notificationOccurred(type)
    }
}
