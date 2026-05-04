import SwiftUI

struct RestaurantDetailView: View {
    @EnvironmentObject private var store: RestaurantStore
    @State private var isEditing = false

    let restaurantID: UUID

    var body: some View {
        if let restaurant = store.restaurants.first(where: { $0.id == restaurantID }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if restaurant.photoFileNames.isEmpty {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.secondarySystemFill))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "camera")
                                    .font(.title)
                                    .foregroundStyle(Color.secondary)
                            )
                    } else {
                        TabView {
                            ForEach(restaurant.photoFileNames, id: \.self) { fileName in
                                if let image = ImageStore.shared.loadImage(fileName: fileName) {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: 240)
                                        .clipped()
                                }
                            }
                        }
                        .frame(height: 240)
                        .tabViewStyle(.page)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(restaurant.name)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Text(restaurant.cuisine)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        RatingView(rating: restaurant.rating)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label(restaurant.location, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Label(restaurant.visitDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if !restaurant.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(restaurant.notes)
                            .font(.body)
                    }
                }
                .padding()
            }
            .navigationTitle("Details")
            .toolbar {
                Button("Edit") {
                    isEditing = true
                }
            }
            .sheet(isPresented: $isEditing) {
                AddEditRestaurantView(mode: .edit(restaurant))
                    .environmentObject(store)
            }
        } else {
            ContentUnavailableView("Restaurant not found", systemImage: "fork.knife")
        }
    }
}
