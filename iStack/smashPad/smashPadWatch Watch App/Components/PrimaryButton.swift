//
//  PrimaryButton.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//


import SwiftUI

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.bold())
                .frame(maxWidth: .infinity)
        }
        .tint(.blue)
        .buttonStyle(.borderedProminent)
    }
}