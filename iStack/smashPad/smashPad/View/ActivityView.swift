//
//  ActivityView.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI
import SwiftData

struct ActivityView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.name)
    private var categories: [Category]

    @State private var showAddCategory = false

    var body: some View {

        NavigationStack {

            ZStack {

                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Header

                    HStack {

                        Text("Activity")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(.primary)

                        Spacer()

                        ConnectivityButton {

                        }
                    }
                    .padding(.bottom, -8)

                    Text("""
                    Pick an activity to track, or add your own.
                    This tracker is best for things where you'll
                    be sitting still, like studying or coding.
                    Please also keep your smart pillow within reach.
                    """)
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)

                    // MARK: Categories

                    ScrollView(showsIndicators: false) {

                        VStack(spacing: 18) {

                            ForEach(categories) { category in

                                ActivityCard(title: category.name) {

                                    // TODO:
                                    // Create Session
                                    // Start Apple Watch
                                    // Navigate to Dashboard

                                    print("Start \(category.name)")
                                }
                            }

                            ActivityButton {
                                showAddCategory = true
                            }
                        }
                        .padding(.top, 10)
                    }

                    Spacer()
                }
                .padding()
            }
            .task {
                createDefaultCategories()
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategory()
            }
        }
    }
}

// MARK: - Seed Data

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
