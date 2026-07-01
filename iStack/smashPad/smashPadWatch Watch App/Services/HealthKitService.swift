//
//  HealthKitService.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import Foundation
import HealthKit
import Combine
import WatchKit

class HealthKitService: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {
    private let healthStore = HKHealthStore()
    private var runtimeSession: WKExtendedRuntimeSession?
    
    @Published var isAuthorized = false
    @Published var currentHeartRate: Double = 0.0
    @Published var isSessionActive = false
    
    // Variabel penyimpan data fisiologis asli user
    @Published var restingHeartRate: Double = 75.0 // Default fallback value
    
    func requestAuthorization() {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return }
        
        // Ask Permission to get Regular Heart Rate and Resting Heart Rate
        let typesToRead: Set = [hrType, rhrType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, _ in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    // if has permission, get user's RHR from database
                    self.fetchRestingHeartRate()
                }
            }
        }
    }
    
    // MARK: - Fetch user's real baseline heartrate
    private func fetchRestingHeartRate() {
        guard let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return }
        
        // Pull average RHR data from last 7 days
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: oneWeekAgo, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: rhrType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            if let result = result, let average = result.averageQuantity() {
                let rhr = average.doubleValue(for: HKUnit(from: "count/min"))
                DispatchQueue.main.async {
                    self.restingHeartRate = rhr
                    print("✅ Real RHR Found: \(rhr) BPM")
                }
            } else {
                print("⚠️ No RHR data on Apple Health, using default 75 BPM")
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Session Control
        func toggleSession() {
            if isSessionActive {
                runtimeSession?.invalidate()
                isSessionActive = false
            } else {
                runtimeSession = WKExtendedRuntimeSession()
                
                runtimeSession?.delegate = self
                runtimeSession?.start()
                startHeartRateQuery()
                isSessionActive = true
            }
        }
    
    // MARK: - Sensor Real-Time
    private func startHeartRateQuery() {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        
        let query = HKAnchoredObjectQuery(type: hrType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, _, _ in
            self?.process(samples)
        }
        query.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.process(samples)
        }
        healthStore.execute(query)
    }
    
    // MARK: - Stress Logic
    private func process(_ samples: [HKSample]?) {
        guard let sample = samples?.last as? HKQuantitySample else { return }
        let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        
        DispatchQueue.main.async {
            self.currentHeartRate = bpm
            
            // Formula: Considered Stress if BPM is more than 30% from RHR
            let stressThreshold = self.restingHeartRate * 1.30
            // Formula: Considered Back to relaxed if BPM falls near RHR
            let relaxedThreshold = self.restingHeartRate * 1.10
            
            if bpm >= stressThreshold {
                ConnectivityManager.shared.sendStressAlert()
                print("🔥 STRESS DETECTED! (BPM: \(bpm) passed threshold \(stressThreshold))")
            } else if bpm <= relaxedThreshold {
                ConnectivityManager.shared.sendRelaxedAlert()
                print("🍏 RELAXED. (BPM: \(bpm) is safe below \(relaxedThreshold))")
            }
        }
    }
    
    func extendedRuntimeSession(_ session: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {}
    func extendedRuntimeSessionDidStart(_ session: WKExtendedRuntimeSession) {}
    func extendedRuntimeSessionWillExpire(_ session: WKExtendedRuntimeSession) {}
}
