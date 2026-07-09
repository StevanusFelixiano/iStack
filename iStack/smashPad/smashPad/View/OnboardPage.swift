//
//  OnboardPage.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct OnboardPage: View {

    @AppStorage("hasSeenOnboarding")
    private var hasSeenOnboarding = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {

        ZStack {

            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 35) {

                Spacer()

                RecoveryIllustration()

                VStack(spacing: 16) {

                    Text("Track Your Recovery")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("View your heart rate trends, recovery progress, and punching history to better understand your tension patterns.")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                Button {
                    hasSeenOnboarding = true
                } label: {

                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .frame(maxWidth: 180)
                        .frame(height: 56)
                        .background(colorScheme == .dark ? .white : .black)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                Spacer()
                    .frame(height: 20)
            }
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    OnboardPage()
        .preferredColorScheme(.dark)
}
#Preview {
    OnboardPage()
        .preferredColorScheme(.light)
}
