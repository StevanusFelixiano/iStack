//
//  ActivityButton.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct ActivityButton: View {

    @Environment(\.colorScheme) private var colorScheme

    let action: () -> Void

    var body: some View {

        Button(action: action) {
            Image(systemName: "plus")
                .font(.title.bold())
                .foregroundStyle(Color(red: 109/255, green: 124/255, blue: 255/255))
                .frame(width: 56, height: 56)
                .background(
                    colorScheme == .dark
                    ? Color(red: 38/255, green: 38/255, blue: 38/255)
                    : Color(.systemGray5)
                )
                .clipShape(Circle())
        }
    }
}

#Preview {
    ActivityButton { }
        .preferredColorScheme(.dark)
}
