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
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - Dipanggil oleh Apple Watch
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
    
    // MARK: - Dipanggil oleh iPhone (Menerima Pesan)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let status = message["status"] as? String {
                self.currentStatus = status
                print("📱 iPhone Menerima Status Baru: \(status)")
            }
        }
    }
    
    // MARK: - WCSession Delegate Boilerplate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    // Kode di bawah ini hanya di-compile untuk target iOS
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}