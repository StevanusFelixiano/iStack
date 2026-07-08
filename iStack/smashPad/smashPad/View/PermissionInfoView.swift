//
//  PermissionInfoView.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 08/07/26.
//

import SwiftUI

struct PermissionInfoView: View {

    let onContinue: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: 28) {

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundStyle(.indigo)

            VStack(alignment: .leading, spacing: 10) {

                Text("Before You Start")
                    .font(.largeTitle.bold())

                Text("""
Thump uses your Apple Watch to monitor your heart rate while you're performing focused activities.

When tracking starts, your Apple Watch will ask for permission to access your heart rate.
""")
                .foregroundStyle(.secondary)
            }
            .padding(.top, 24)

            VStack(alignment: .leading, spacing: 16) {

                Label(
                    "Continuous heart rate monitoring may increase Apple Watch battery usage during active sessions.",
                    systemImage: "battery.25"
                )

                Label(
                    "Make sure your Apple Watch is connected to your iPhone and worn securely.",
                    systemImage: "applewatch"
                )
            }
            .font(.subheadline)
            .padding()
            .background(.orange.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Spacer()

            Button {

                onContinue()

            } label: {

                Text("Continue")
                    .font(.headline)
                    .frame(width: 220)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .padding(.horizontal, 55)

        }
        .padding(24)
    }
}

#Preview {

    PermissionInfoView {

        print("Continue")

    }
}
