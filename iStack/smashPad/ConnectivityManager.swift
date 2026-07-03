//
//  ConnectivityManager.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import Foundation
import WatchConnectivity
import Combine

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    @Published var currentStatus: String = "relaxed"
    // Added property to track watch session state
    @Published var isWatchSessionActive: Bool = false
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - Methods called by Apple Watch
    func sendStressAlert() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["status": "stressed"], replyHandler: nil)
        }
    }
    
    func sendRelaxedAlert() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["status": "relaxed"], replyHandler: nil)
        }
    }
    
    // MARK: - Methods called by iPhone (To Apple Watch)
    func sendStartCommandToWatch() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["command": "start"], replyHandler: nil)
            isWatchSessionActive = true // Update UI state
            print("📱 iPhone sent START command to Watch")
        }
    }
    
    func sendStopCommandToWatch() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["command": "stop"], replyHandler: nil)
            isWatchSessionActive = false // Update UI state
            print("📱 iPhone sent STOP command to Watch")
        }
    }
    
    // MARK: - Message Receiver
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let status = message["status"] as? String {
                self.currentStatus = status
                print("📱 iPhone received new status: \(status)")
            }
        }
    }
    
    // MARK: - WCSession Delegate Boilerplate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
