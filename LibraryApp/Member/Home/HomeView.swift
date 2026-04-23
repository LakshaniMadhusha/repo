import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [ReadingSession]

    let user: AppUser
    @State private var vm = HomeViewModel()
    @State private var selectedCategory = "All"
    
    private let categories = ["All", "Fiction", "Non-Fiction", "Science", "History", "Technology"]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Feature Cards
                HStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "flame.fill").foregroundColor(.orange).font(.title2)
                        Text("\(vm.readingStreak)").font(.title.weight(.bold))
                        Text("Streak").font(.caption)
                    }
                    .frame(maxWidth: .infinity).padding().background(Color.cardBg).cornerRadius(16)

                    VStack(spacing: 8) {
                        Image(systemName: "star.fill").foregroundColor(.yellow).font(.title2)
                        Text("\(vm.rewardPoints)").font(.title.weight(.bold))
                        Text("Points").font(.caption)
                    }
                    .frame(maxWidth: .infinity).padding().background(Color.cardBg).cornerRadius(16)
                }
                .padding(.horizontal, 20)
                
                // Current Reading
                if !vm.activeLoans.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Reading").font(.title2.weight(.bold)).padding(.horizontal, 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(vm.activeLoans.prefix(3)) { loan in
                                    if let book = loan.book {
                                        BookCoverCard(book: book, width: 100, height: 150)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color.pageBg.ignoresSafeArea())
        .navigationTitle("Dashboard")
        .task { await vm.load(user: user, modelContext: modelContext) }
    }
}
