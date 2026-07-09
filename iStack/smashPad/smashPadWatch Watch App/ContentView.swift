import SwiftUI
import HealthKit

// MARK: - Enum untuk Alur Izin
enum PermissionStep {
    case heartRate
    case bodyMovement
    case completed
}

struct ContentView: View {
    @AppStorage("hasCompletedWatchOnboarding") private var hasCompletedWatchOnboarding: Bool = false
    
    @StateObject private var hkService = HealthKitService.shared
    @StateObject private var connectivity = ConnectivityManager.shared
    @State private var currentStep: PermissionStep = .heartRate
        
    // MARK: - State Timer & Data
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var punchCount: Int = 0
        
    private var durationString: String {
        let minutes = Int(connectivity.elapsedTime) / 60
        let seconds = Int(connectivity.elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ScrollView {
            if hasCompletedWatchOnboarding {
                if hkService.isSessionActive {
                    activeSessionView
                } else {
                    noSessionView
                }
            } else {
                switch currentStep {
                    case .heartRate:
                        heartRatePermissionView
                            .transition(.push(from: .trailing))
                    case .bodyMovement:
                        bodyMovementPermissionView
                            .transition(.push(from: .trailing))
                    case .completed:
                        ProgressView("Loading...")
                            .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut, value: currentStep)
        .animation(.easeInOut, value: hkService.isSessionActive)
        .animation(.default, value: hasCompletedWatchOnboarding)
    }
    
    // MARK: - Subviews Onboarding & Dashboard
    
    private var heartRatePermissionView: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart")
                .font(.system(size: 36))
                .foregroundStyle(.indigo)
            
            Text("Allow Heart Rate Access")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Your heart rate is used to detect potential tension and start recovery sessions.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                print("Tapped")
                //ubah disini
                hkService.requestAuthorization1 { success in
                    print("Permission callback")
                    guard success else { return }

                    withAnimation {
                        currentStep = .bodyMovement
                    }
                }
            } label: {
                Text("Accept")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .frame(width: 163)
        }
        .padding(.horizontal)
        .padding(.top, -14)
    }
    
    private var bodyMovementPermissionView: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 36))
                .foregroundStyle(.indigo)
            
            Text("Monitor Body Movement")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("To ensure potential tension episodes alerts are only triggered when you are at rest.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
            hkService.requestMotionAuthorization { success in
                guard success else { return }

                DispatchQueue.main.async {
                    withAnimation {
                        currentStep = .completed
                        hasCompletedWatchOnboarding = true
                    }
                }
            }
        } label: {
            Text("Accept")
                .frame(maxWidth: .infinity)
        }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .frame(width: 163)
        }
        .padding(.horizontal)
        .padding(.top, -14)
    }
    
    private var noSessionView: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("No Session Started")
                .font(.system(size: 16, weight: .semibold))
            
            Text("Try start a session\nfrom the app")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var activeSessionView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top) {
                Text("\(connectivity.punchCount)")
                    .font(.system(size: 40, weight: .regular))
                
                Spacer()
                
                if hkService.isPaused {
                    Text("Paused")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                        .padding(.top, 10)
                }
            }
            
            Text("TIMES PILLOW PUNCHED")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
            
            // Menampilkan Timer MM:SS
            Text(durationString)
                .font(.system(size: 38, weight: .regular))
                .foregroundColor(hkService.isPaused ? .gray : Color(red: 0.4, green: 0.6, blue: 1.0))
            
            Text("DURATION")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
            
            Spacer(minLength: 16)
            
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        hkService.stopSession()
                        connectivity.sendCommandToPhone("stop")
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                }
                .frame(width: 54, height: 54)
                .background(Circle().fill(Color(red: 0.3, green: 0.1, blue: 0.1)))
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    withAnimation {
                        if hkService.isPaused {
                            hkService.resumeSession()
                            connectivity.sendCommandToPhone("resume")
                        } else {
                            hkService.pauseSession()
                            connectivity.sendCommandToPhone("pause")
                        }
                    }
                }) {
                    Image(systemName: hkService.isPaused ? "arrow.clockwise" : "pause")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(hkService.isPaused ? Color(red: 0.4, green: 0.6, blue: 1.0) : .white)
                }
                .frame(width: 54, height: 54)
                .background(Circle().fill(hkService.isPaused ? Color(red: 0.1, green: 0.1, blue: 0.3) : Color(white: 0.2)))
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // testing buttons
            .padding(.bottom, 16)
            
            Divider()
            
            VStack(spacing: 12) {
                Text("Test/Simulation Mode")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                let stressThreshold = hkService.restingHeartRate * 1.30
                let isStressed = hkService.currentHeartRate >= stressThreshold && hkService.currentHeartRate > 0
           
               VStack(spacing: 2) {
                   Text("Current BPM")
                       .font(.footnote)
                       .foregroundColor(.secondary)
                   
                   Text("\(hkService.currentHeartRate, specifier: "%.0f") ❤️")
                       .font(.system(size: 48, weight: .bold, design: .rounded))
                       .foregroundColor(isStressed ? .red : .green)
               }
               .padding(.top, 8)
                
                VStack(spacing: 2) {
                    Text("Baseline RHR: \(hkService.restingHeartRate, specifier: "%.0f") BPM")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("Heart Rate Limit: > \(stressThreshold, specifier: "%.0f") BPM")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.bottom, 8)
                    
                    HStack(spacing: 8) {
                        Button("🔥 Stress") {
                            hkService.triggerDebugStress()
                        }
                        .tint(.red)
                        .buttonStyle(.borderedProminent)
                        
                        Button("🍏 Relax") {
                            hkService.triggerDebugRelax()
                        }
                        .tint(.green)
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Button("🔄 Reset") {
                        hkService.resetSimulation()
                    }
                    .tint(.blue)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, -20)
    }
}
    

#Preview{
    ContentView()
}

//// MARK: - Tampilan Standby (Menunggu Sesi dari iPhone)
//struct StandbyView: View {
//    @State private var isPulsing = false

