import SwiftUI
import HealthKit

// 1. Define the enum for the permission flow steps
enum PermissionStep {
    case heartRate
    case bodyMovement
    case completed
}

struct ContentView: View {
    @StateObject private var hkService = HealthKitService.shared
    
    @State private var currentStep: PermissionStep = .heartRate
    
    @State private var isMotionAuthorized: Bool = false
    
    var body: some View {
        ScrollView {
            
            if hkService.isAuthorized && isMotionAuthorized {
                mainDashboardView
            } else {
    
                switch currentStep {
                case .heartRate:
                    heartRatePermissionView
                case .bodyMovement:
                    bodyMovementPermissionView
                case .completed:
                    ProgressView("Loading...") // Temporary state while services update
                }
            }
        }
        .onAppear {
            if hkService.isAuthorized && isMotionAuthorized {
                hkService.startSessionIfNeeded()
            }
        }
    }
    
    // MARK: - Subviews
    
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
                hkService.requestAuthorization()
                // 4. Transition to the next screen
                withAnimation {
                    currentStep = .bodyMovement
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
                // Execute motion permission logic here (e.g., CMMotionActivityManager)
                // motionService.requestAuthorization()
                
                // Update final states
                isMotionAuthorized = true // Hardcoded for simulation, replace with actual service check
                
                withAnimation {
                    currentStep = .completed
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
    
    private var mainDashboardView: some View {
        VStack(spacing: 12) {
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
            }
            .padding(.bottom, 8)
            
            Divider()
                .padding(.vertical, 4)
            
            Text("Test/Simulation Mode")
                .font(.caption2)
                .foregroundColor(.gray)
            
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
        .padding(.horizontal)
        .padding(.top, -14)
    }
}

#Preview{
    ContentView()
}
