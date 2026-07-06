//
//  AppThemeManager.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct AppThemeManager<Content: View>: View {

    @AppStorage("isDarkMode")
    private var isDarkMode = true

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
