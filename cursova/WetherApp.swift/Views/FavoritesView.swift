import SwiftUI

struct FavoritesView: View {

    @ObservedObject var favorites: FavoritesManager
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            if favorites.favorites.isEmpty {
                Text("У вас ще немає улюблених міст.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(favorites.favorites, id: \.self) { city in
                        Button {
                            onSelect(city)
                        } label: {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)

                                Text(city)
                                    .font(.title3)
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("Улюблені міста")
    }
}
