//
//  ActivityView.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI
import SwiftData

struct ActivityView: View {
    @State private var selectedCategory: Category?
    @State private var showDeviceAlert = false
    @AppStorage("hasSeenTrackingPermissionInfo")
    private var hasSeenTrackingPermissionInfo = false
    
    @State private var showConnectivity = false
    @State private var path = NavigationPath()
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.name)
    private var categories: [Category]

    @State private var showAddCategory = false
    
    private func deleteCategory(_ category: Category) {
        modelContext.delete(category)
    }
    
    private func startSession(for category: Category) {
        BluetoothService.shared.resetSession()
        let session = Session(
            category: category,
            startTime: .now,
            averageRestingHR:
            Int(ConnectivityManager.shared.restingHeartRate.rounded())
        )

        modelContext.insert(session)

        ConnectivityManager.shared.sendStartCommandToWatch()

        path.append(session)
    }
    
    private var canStartSession: Bool {
        ConnectivityManager.shared.isWatchConnected &&
        BluetoothService.shared.isConnected
    }

    var body: some View {

        NavigationStack(path: $path) {

            ZStack {

                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {

                    HStack {

                        Text("Activity")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Spacer()

                        ConnectivityButton (size: 44, iconSize: 22){
                            showConnectivity.toggle()
                        }
                        .popover(
                            isPresented: $showConnectivity,
                            attachmentAnchor: .point(.bottomTrailing),
                            arrowEdge: .top
                        ) {
                            ConnectivityMenu(isPresented: $showConnectivity)
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                    .padding(.top, -20)

                    Text("""
                    Pick an activity to track, or add your own.
                    This tracker is best for things where you'll
                    be sitting still, like studying or coding.
                    Please also keep your smart pillow within
                    reach.
                    """)
                    .font(.system(size: 20))
                    .foregroundStyle(.primary)

                    List {
                        ForEach(categories) { category in

                            ActivityCard(title: category.name) {

//                                guard canStartSession else {
//                                    showDeviceAlert = true
//                                    return
//                                }

                                if hasSeenTrackingPermissionInfo {
                                    startSession(for: category)
                                } else {
                                    selectedCategory = category
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 9, leading: 0, bottom: 9, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {

                                Button(role: .destructive) {
                                    modelContext.delete(category)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .tint(Color.red)
                        }

                        HStack {
                            Spacer()

                            HStack {
                                Spacer()

                                ActivityButton {
                                    withAnimation(.spring(response: 0.35)) {
                                        showAddCategory = true
                                    }
                                }

                                Spacer()
                            }
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)

                    Spacer()
                }
                .padding()

                if showAddCategory {

                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35)) {
                                showAddCategory = false
                            }
                        }

                    AddCategory(isPresented: $showAddCategory)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            .navigationDestination(for: Session.self) { session in
                TrackingPage(session: session)
            }
            .sheet(item: $selectedCategory) { category in

                PermissionInfoView {

                    hasSeenTrackingPermissionInfo = true

                    selectedCategory = nil

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

                        startSession(for: category)

                    }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .alert(
                "Devices Not Ready",
                isPresented: $showDeviceAlert
            ) {

                Button("OK", role: .cancel) { }

            } message: {

                Text("""
                Please make sure your Apple Watch and Smart Pillow are connected before starting a monitoring session.
                """)
            }
            .task {
                NotificationManager.shared.requestPermission()
                ConnectivityManager.shared.requestHealthKitAuthorizationOnPhone()
                createDefaultCategories()
            }
        }
    }
}

private extension ActivityView {

    func createDefaultCategories() {

        guard categories.isEmpty else { return }

        modelContext.insert(Category(name: "Studying"))
        modelContext.insert(Category(name: "Coding"))
        modelContext.insert(Category(name: "Gaming"))
    }
}

#Preview {
    ActivityView()
        .preferredColorScheme(.dark)
        .modelContainer(for: Category.self, inMemory: true)
}
#Preview {
    ActivityView()
        .preferredColorScheme(.light)
        .modelContainer(for: Category.self, inMemory: true)
}
