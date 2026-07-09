//
//  TrackingPage.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI
import SwiftData

enum MonitoringState {
    case relaxed
    case stressedPendingAction
    case recovering
}

struct TrackingPage: View {
    @StateObject
    private var connectivity = ConnectivityManager.shared
    
    @Bindable var session: Session
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showConnectivity = false
    
    @State private var isPaused = false
    @State private var isExpanded = false
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var lastSavedBPM = -1
    @State private var showCancelConfirmation = false
    
    @State
    private var monitoringState: MonitoringState = .relaxed

    @State
    private var lastRelaxedAt: Date = .distantPast

    private let cooldown: TimeInterval = 60
    
    @StateObject
    private var bluetooth = BluetoothService.shared
    
    @State
    private var activeTenseEvent: TenseEvent?
    
    @State
    private var firstPunchReceived = false
    
    @State
    private var falsePositiveTimer: Timer?
    
    // MARK: - Timer
    
    private var displayedElapsedTime: TimeInterval {
        
        if let endTime = session.endTime {
            
            return max(
                endTime.timeIntervalSince(session.startTime)
                - session.totalPausedDuration,
                0
            )
        }
        
        if let pausedAt = session.pausedAt {
            
            return max(
                pausedAt.timeIntervalSince(session.startTime)
                - session.totalPausedDuration,
                0
            )
        }
        
        return max(
            Date().timeIntervalSince(session.startTime)
            - session.totalPausedDuration,
            0
        )
    }
    
    private func saveHeartRate(_ bpm: Double) {
        
        let value = Int(bpm.rounded())
        
        guard value != lastSavedBPM else { return }
        
        lastSavedBPM = value
        
        let heartRate = HeartRate(
            heartRateBPM: value,
            timestamp: .now,
            session: session
        )
        
        modelContext.insert(heartRate)
        
        try? modelContext.save()
    }
    
    private func startFalsePositiveTimer() {
        
        guard activeTenseEvent == nil else { return }
        guard falsePositiveTimer == nil else { return }
        
        firstPunchReceived = false
        
        falsePositiveTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: false
        ) { _ in
            
            guard !firstPunchReceived else { return }
            
            print("False Positive")
            
            monitoringState = .relaxed
            lastRelaxedAt = .now
            firstPunchReceived = false
            falsePositiveTimer = nil
            bluetooth.turnOffPillowLED()
            
        }
    }
    
    private func receivePunch(_ intensity: Double) {
        guard monitoringState == .stressedPendingAction ||
              monitoringState == .recovering else {

            print("Playful punch ignored.")
            return
        }
        
        if activeTenseEvent == nil {
            
            falsePositiveTimer?.invalidate()
            falsePositiveTimer = nil
            
            bluetooth.turnOffPillowLED()
            
            firstPunchReceived = true
            
            let event = TenseEvent(
                startingHeartRate: Int(connectivity.latestHeartRate.rounded()),
                detectedAt: .now,
                recoveryStartedAt: .now,
                session: session
            )
            
            modelContext.insert(event)
            
            activeTenseEvent = event
            monitoringState = .recovering
        }
        
        guard let event = activeTenseEvent else { return }
        
        let punch = Punch(
            punchIntensity: Float(intensity),
            timestamp: .now,
            tenseEvent: event
        )
        
        modelContext.insert(punch)
        
        try? modelContext.save()
    }
    
    private func finishRecovery(save: Bool = true) {
        
        guard let event = activeTenseEvent else { return }
        
        event.recoveryEndedAt = .now
        
        if save {
            try? modelContext.save()
        }
        monitoringState = .relaxed
        lastRelaxedAt = .now
        activeTenseEvent = nil
        
        firstPunchReceived = false
        
        falsePositiveTimer?.invalidate()
        falsePositiveTimer = nil
    }
    
    private func startTimer() {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            DispatchQueue.main.async {
                
                elapsedTime = displayedElapsedTime
                
            }
        }
    }
    
    private func pauseTimer() {
        
        timer?.invalidate()
    }
    
    private func resumeTimer() {
        
        startTimer()
    }
    
    private func stopTimer() {
        
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Pause / Resume
    
    private func togglePauseResume() {
        withAnimation(.spring()) {
            isPaused.toggle()
            isExpanded.toggle()
        }
        
        if isPaused {
            
            session.pausedAt = .now
            
            try? modelContext.save()
            
            pauseTimer()
            
            ConnectivityManager.shared.sendPauseCommandToWatch()
            
        } else {
            
            if let pausedAt = session.pausedAt {
                
                session.totalPausedDuration +=
                Date().timeIntervalSince(pausedAt)
                
                session.pausedAt = nil
            }
            
            try? modelContext.save()
            elapsedTime = displayedElapsedTime
            
            resumeTimer()
            
            ConnectivityManager.shared.sendResumeCommandToWatch()
        }
    }
    
    // MARK: - Session
    
    private func cancelSession() {
        bluetooth.turnOffPillowLED()
        falsePositiveTimer?.invalidate()
        falsePositiveTimer = nil
        
        stopTimer()
        
        ConnectivityManager.shared.sendStopCommandToWatch()
        
        activeTenseEvent = nil
        firstPunchReceived = false
        
        modelContext.delete(session)
        
        try? modelContext.save()
        
        dismiss()
    }
    
    private func endSession() {
        bluetooth.turnOffPillowLED()
        falsePositiveTimer?.invalidate()
        falsePositiveTimer = nil
        
        stopTimer()
        
        ConnectivityManager.shared.sendStopCommandToWatch()
        
        if let pausedAt = session.pausedAt {
            
            session.totalPausedDuration +=
            Date().timeIntervalSince(pausedAt)
            
            session.pausedAt = nil
        }
        if activeTenseEvent != nil {
                finishRecovery(save: false)
            } else {
                monitoringState = .relaxed
            }
        
        session.endTime = .now
        
        // Update timer terakhir supaya sesuai data yang disimpan
        elapsedTime = displayedElapsedTime
        
        try? modelContext.save()
        
        dismiss()
    }
    
    // MARK: - UI
    
    var body: some View {
        
        ZStack {
            
            Image("GradientOval1")
                .resizable()
                .scaledToFill()
            
            VStack(spacing: 0) {
                
                TrackingTopBar(
                    showConnectivity: $showConnectivity
                ) {
                    showCancelConfirmation = true
                }
                .padding(.bottom, 36)
                
                TrackingInfo(session: session)
                    .padding(.bottom, 100)
                
                PunchCounter(
                    punchCount: bluetooth.punchCount
                )
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            
            VStack(spacing: 0) {
                
                Spacer()
                
                TrackingControlPanel(
                    isPaused: $isPaused,
                    isExpanded: $isExpanded,
                    elapsedTime: $elapsedTime,
                    onPauseResume: togglePauseResume,
                    onEndSession: endSession
                )
            }
            .ignoresSafeArea(edges: .bottom)
            
            if showConnectivity {
                
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        
                        withAnimation(.spring()) {
                            showConnectivity = false
                        }
                    }
                
                VStack {
                    
                    HStack {
                        
                        Spacer()
                        
                        ConnectivityMenu(isPresented: $showConnectivity)
                    }
                    
                    Spacer()
                }
                .padding(.top, 66)
                .padding(.trailing, 24)
                .transition(
                    .scale(scale: 0.95, anchor: .topTrailing)
                    .combined(with: .opacity)
                )
                .zIndex(999)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            elapsedTime = displayedElapsedTime
            
            startTimer()
        }
        .onReceive(connectivity.$latestHeartRate) { bpm in
            
            guard bpm > 0 else { return }
            
            saveHeartRate(bpm)
        }
        .onReceive(connectivity.$currentStatus) { status in
            
            switch status {
                
            case "stressed":

                guard monitoringState == .relaxed else {
                    return
                }

                monitoringState = .stressedPendingAction

                NotificationManager.shared.showTensionNotification()

                bluetooth.turnOnPillowLED()

                startFalsePositiveTimer()
                
            case "relaxed":

                switch monitoringState {

                case .stressedPendingAction:
                    // false alarm
                    bluetooth.turnOffPillowLED()

                    falsePositiveTimer?.invalidate()
                    falsePositiveTimer = nil

                    monitoringState = .relaxed
                    lastRelaxedAt = .now

                case .recovering:
                    finishRecovery()

                case .relaxed:
                    break
                }
                
            default:
                break
            }
        }
        .onReceive(bluetooth.$lastPunchIntensity) { intensity in
            
            guard intensity > 0 else { return }
            
            receivePunch(intensity)
        }
        .onDisappear {
            
            stopTimer()
            falsePositiveTimer?.invalidate()
            falsePositiveTimer = nil
        }
        .alert(
            "Discard Session?",
            isPresented: $showCancelConfirmation
        ) {

            Button("Cancel", role: .cancel) { }

            Button("Discard Session", role: .destructive) {
                cancelSession()
            }

        } message: {

            Text("If you leave now, this monitoring session will be discarded and none of the collected data will be saved.")

        }
    }
}

#Preview {
    
    do {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let container = try ModelContainer(
            for: Category.self,
            Session.self,
            HeartRate.self,
            TenseEvent.self,
            Punch.self,
            configurations: config
        )
        
        let category = Category(name: "Studying")
        
        container.mainContext.insert(category)
        
        let session = Session(
            category: category,
            startTime: .now,
            averageRestingHR: 75
        )
        
        container.mainContext.insert(session)
        
        return NavigationStack {
            
            TrackingPage(session: session)
            
        }
        .modelContainer(container)
        
    } catch {
        
        return Text("Preview Error")
        
    }
}
