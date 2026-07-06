//
//  AddCategory.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI
import SwiftData

struct AddCategory: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @State private var categoryName = ""

    var body: some View {

        NavigationStack {

            ZStack {

                (colorScheme == .dark ? Color.black : Color.white)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {

                    Text("New Activity")
                        .font(.largeTitle.bold())
                        .foregroundStyle(colorScheme == .dark ? .white : .black)

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Activity Name")
                            .foregroundStyle(.gray)

                        TextField("e.g. Reading", text: $categoryName)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        colorScheme == .dark
                                        ? Color.white.opacity(0.08)
                                        : Color.black.opacity(0.06)
                                    )
                            )
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }

                    Spacer()

                    Button {
                        saveCategory()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.gray
                                : Color(red: 109/255, green: 124/255, blue: 255/255)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
        }
    }

    private func saveCategory() {

        let name = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else { return }

        modelContext.insert(Category(name: name))
        dismiss()
    }
}

#Preview {
    AddCategory()
        .modelContainer(for: Category.self, inMemory: true)
        .preferredColorScheme(.dark)
}
