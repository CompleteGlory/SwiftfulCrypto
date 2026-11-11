//
//  CircleButtonView.swift
//  SwiftfulCrypto
//
//  Created by Magd on 24/10/2026.
//

import SwiftUI

struct CircleButtonView: View {
    
    let iconName: String
    var body: some View {
        Image(systemName: iconName)
            .font(.headline)
            .foregroundStyle(Color.theme.accent)
            .frame(width: 50,height: 50)
            .background(
                Circle()
                    .foregroundStyle(Color.theme.backGround)
            )
            .shadow(color: Color.theme.accent.opacity(0.25), radius: 10, x:0,  y:0)
            .padding()
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    Group{
        CircleButtonView(iconName: "info")
            .padding()
        
        CircleButtonView(iconName: "plus")
            .padding()
            .colorScheme(.dark)
    }
   
        
}
