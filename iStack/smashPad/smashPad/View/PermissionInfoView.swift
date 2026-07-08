import SwiftUI

struct PermissionInfoView: View {
    let onContinue: () -> Void
    
    var body: some View {
    ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 24) {
            
            // Header Icon
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 48))
                .foregroundStyle(.indigo)
                .padding(.top, 24)
            
            // Main Title
            Text("Things You Should Know")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            // Scrollable Information List (Added ScrollView for the extra point)
            
            VStack(spacing: 28) {
                NumberedListItem(
                    index: "1",
                    title: "Session Tracking",
                    description: "Thump uses your Apple Watch to monitor your heart rate during focused activities"
                )
                
                NumberedListItem(
                    index: "2",
                    title: "Device Requirements",
                    description: "Ensure your Apple Watch is worn securely and connected to your iPhone. Continuous tracking may increase battery usage"
                )
                
                NumberedListItem(
                    index: "3",
                    title: "Not a Medical Device",
                    description: "Thump provides observational data only. It should not be used to assess psychological stress, make medical decisions, or replace professional healthcare advice"
                )
                
                // New Privacy Point
                NumberedListItem(
                    index: "4",
                    title: "Data Privacy",
                    description: "Your heart rate and session data are stored securely. We only collect data during active sessions and do not share your personal information with third parties"
                )
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        
        // Action Button
        Button {
            onContinue()
        } label: {
            Text("Accept")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(.indigo)
        .clipShape(Capsule())
        .padding(.bottom, 8)
    }
        .padding(.horizontal, 24)
        .preferredColorScheme(.dark)

    }
}

// Modular component for leading circle index alignment
struct NumberedListItem: View {
    let index: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            // Leading numerical indicator
            Text(index)
                .font(.headline)
                .bold()
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.indigo))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PermissionInfoView {
        print("Accept action executed")
    }
}
