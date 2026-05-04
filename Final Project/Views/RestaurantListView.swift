import SwiftUI

struct RestaurantListView: View {
    @EnvironmentObject private var store: RestaurantStore
    @State private var searchText = ""
    @State private var sortOption: SortOption = .recent
    @State private var isAdding = false
    @State private var randomRestaurant: Restaurant? = nil
    @State private var nearMeActive = false
    @StateObject private var locationManager = LocationManager()
    var body: some View {
        NavigationStack {
            List {
                if filteredRestaurants.isEmpty {
                    ContentUnavailableView(
                        "No Restaurants",
                        systemImage: "fork.knife",
                        description: Text("Add your first restaurant to get started.")
                    )
                } else {
                    ForEach(filteredRestaurants) { restaurant in
                        NavigationLink {
                            RestaurantDetailView(restaurantID: restaurant.id)
                                .environmentObject(store)
                        } label: {
                            RestaurantRowView(restaurant: restaurant)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Restaurant Journal")
            .searchable(text: $searchText, prompt: "Search by name, cuisine, or notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAdding = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        randomRestaurant = store.restaurants.randomElement()
                    } label: {
                        Label("Pick Random", systemImage: "dice")
                    }
                    .disabled(store.restaurants.isEmpty)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        nearMeActive.toggle()
                        if nearMeActive {
                            locationManager.requestLocation()
                        }
                    } label: {
                        Label("Near Me", systemImage: nearMeActive ? "location.fill" : "location")
                    }
                    .disabled(store.restaurants.isEmpty)
                }
            }
            .sheet(isPresented: $isAdding) {
                AddEditRestaurantView(mode: .add)
                    .environmentObject(store)
            }
            .sheet(item: $randomRestaurant) { restaurant in
                NavigationStack {
                    RestaurantDetailView(restaurantID: restaurant.id)
                        .environmentObject(store)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { randomRestaurant = nil }
                            }
                        }
                }
            }
        }
    }

    private var filteredRestaurants: [Restaurant] {
        var base = store.sorted(by: sortOption)

        if nearMeActive, let city = locationManager.city {
            base = base.filter {
                $0.location.localizedCaseInsensitiveContains(city)
            }
        }

        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return base
        }
        return base.filter { restaurant in
            let needle = searchText.lowercased()
            return restaurant.name.lowercased().contains(needle) ||
                restaurant.cuisine.lowercased().contains(needle) ||
                restaurant.notes.lowercased().contains(needle)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let restaurant = filteredRestaurants[index]
            store.delete(restaurant)
        }
    }
}
