//
//  SummaryView.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct SummaryView: View {

    var body: some View {

        ZStack {

            Color(.systemBackground)
                .ignoresSafeArea()

            Text("Summary")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    SummaryView()
        .preferredColorScheme(.dark)
}
