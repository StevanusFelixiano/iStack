//
//  smashPadWatchApp.swift
//  smashPadWatch Watch App
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import SwiftUI
import WatchKit
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        print("⌚️ Watch menangkap sinyal Wake Up dari iPhone! Memulai session...")
        
        HealthKitService.shared.startSession()
    }
}

@main
struct smashPadWatch_Watch_AppApp: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
