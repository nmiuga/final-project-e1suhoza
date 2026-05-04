import SwiftUI

struct RestaurantRowView: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: 12) {
            if let firstPhoto = restaurant.photoFileNames.first,
               let image = ImageStore.shared.loadImage(fileName: firstPhoto) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.secondarySystemFill))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .foregroundStyle(Color.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                Text(restaurant.cuisine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                RatingView(rating: restaurant.rating)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}
