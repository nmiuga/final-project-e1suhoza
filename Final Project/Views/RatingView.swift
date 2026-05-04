import SwiftUI

struct RatingView: View {
    let rating: Int
    let maxRating: Int

    init(rating: Int, maxRating: Int = 5) {
        self.rating = rating
        self.maxRating = maxRating
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { value in
                Image(systemName: value <= rating ? "star.fill" : "star")
                    .foregroundStyle(value <= rating ? Color.orange : Color.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) out of \(maxRating)")
    }
}
