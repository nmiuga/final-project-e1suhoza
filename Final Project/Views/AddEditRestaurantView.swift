import PhotosUI
import SwiftUI

struct AddEditRestaurantView: View {
    enum Mode {
        case add
        case edit(Restaurant)
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RestaurantStore

    @State private var name: String
    @State private var cuisine: String
    @State private var location: String
    @State private var visitDate: Date
    @State private var rating: Int
    @State private var notes: String
    @State private var existingPhotoFileNames: [String]

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var newPhotoFileNames: [String] = []

    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode

        switch mode {
        case .add:
            _name = State(initialValue: "")
            _cuisine = State(initialValue: "")
            _location = State(initialValue: "")
            _visitDate = State(initialValue: Date())
            _rating = State(initialValue: 3)
            _notes = State(initialValue: "")
            _existingPhotoFileNames = State(initialValue: [])
        case .edit(let restaurant):
            _name = State(initialValue: restaurant.name)
            _cuisine = State(initialValue: restaurant.cuisine)
            _location = State(initialValue: restaurant.location)
            _visitDate = State(initialValue: restaurant.visitDate)
            _rating = State(initialValue: restaurant.rating)
            _notes = State(initialValue: restaurant.notes)
            _existingPhotoFileNames = State(initialValue: restaurant.photoFileNames)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Restaurant name", text: $name)
                    TextField("Cuisine", text: $cuisine)
                    TextField("Location", text: $location)
                }

                Section("Visit") {
                    DatePicker("Date", selection: $visitDate, displayedComponents: .date)
                    RatingPicker(rating: $rating)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }

                Section("Photos") {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 6,
                        matching: .images
                    ) {
                        Label("Add Photos", systemImage: "camera")
                    }

                    if existingPhotoFileNames.isEmpty && newPhotoFileNames.isEmpty {
                        Text("No photos yet")
                            .foregroundStyle(.secondary)
                    } else {
                        photoGrid
                    }
                }
            }
            .navigationTitle(modeTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRestaurant()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: selectedItems) { items in
                Task {
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let fileName = try? ImageStore.shared.saveImageData(data) {
                            newPhotoFileNames.append(fileName)
                        }
                    }
                    selectedItems = []
                }
            }
        }
    }

    private var modeTitle: String {
        switch mode {
        case .add:
            return "Add Restaurant"
        case .edit:
            return "Edit Restaurant"
        }
    }

    private var photoGrid: some View {
        let allPhotos = existingPhotoFileNames + newPhotoFileNames
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], spacing: 12) {
            ForEach(allPhotos, id: \.self) { fileName in
                ZStack(alignment: .topTrailing) {
                    if let image = ImageStore.shared.loadImage(fileName: fileName) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    Button {
                        removePhoto(fileName: fileName)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.white, Color.black.opacity(0.6))
                    }
                    .offset(x: 6, y: -6)
                }
            }
        }
    }

    private func removePhoto(fileName: String) {
        if let index = existingPhotoFileNames.firstIndex(of: fileName) {
            existingPhotoFileNames.remove(at: index)
            ImageStore.shared.deleteImage(fileName: fileName)
            return
        }
        if let index = newPhotoFileNames.firstIndex(of: fileName) {
            newPhotoFileNames.remove(at: index)
            ImageStore.shared.deleteImage(fileName: fileName)
        }
    }

    private func saveRestaurant() {
        let combinedPhotos = existingPhotoFileNames + newPhotoFileNames
        let cleanedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .add:
            let restaurant = Restaurant(
                name: name,
                cuisine: cuisine,
                location: location,
                visitDate: visitDate,
                rating: rating,
                notes: cleanedNotes,
                photoFileNames: combinedPhotos
            )
            store.add(restaurant)
        case .edit(let restaurant):
            var updated = restaurant
            updated.name = name
            updated.cuisine = cuisine
            updated.location = location
            updated.visitDate = visitDate
            updated.rating = rating
            updated.notes = cleanedNotes
            updated.photoFileNames = combinedPhotos
            store.update(updated)
        }
    }
}

private struct RatingPicker: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...5, id: \.self) { value in
                Button {
                    rating = value
                } label: {
                    Image(systemName: value <= rating ? "star.fill" : "star")
                        .foregroundStyle(value <= rating ? Color.orange : Color.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            Spacer()
            Text("\(rating)/5")
                .foregroundStyle(.secondary)
        }
    }
}
