//
//  HeartRateDisplay.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//


import SwiftUI

struct HeartRateDisplay: View {
    var bpm: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("BPM Kamu:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .lastTextBaseline) {
                Text("\(bpm, specifier: "%.0f")")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                Text("❤️")
                    .font(.title)
            }
        }
    }
}
