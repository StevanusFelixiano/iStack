//
//  TrackingTopBar.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI

struct TrackingTopBar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var showConnectivity: Bool
    let onBack: () -> Void

    var body: some View {

        HStack {

            Button(action: onBack) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .frame(width: 48, height: 48)
                    .glassEffect(in: Circle())
                    .overlay {
                        Circle()
                            .stroke(
                                colorScheme == .dark
                                ? .white.opacity(0.25)
                                : .black.opacity(0.15),
                                lineWidth: 1.5
                            )
                    }
            }

            Spacer()

            ConnectivityButton {

                withAnimation(.spring(response: 0.35)) {
                    showConnectivity.toggle()
                }
            }
        }
    }
}

#Preview {

    TrackingTopBar(
        showConnectivity: .constant(true),
        onBack: {}
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview {

    TrackingTopBar(
        showConnectivity: .constant(true),
        onBack: {}
    )
    .padding()
    .preferredColorScheme(.light)
}
