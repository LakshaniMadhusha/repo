import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [ReadingSession]
    
    let user: AppUser
    @State private var vm = HomeViewModel()
    @State private var searchText = ""
    @State private var showingTracker = false
    @State private var showingHistory = false

    var body: some View {
        let todayMins = sessions.filter { Calendar.current.isDateInToday($0.startedAt) }.reduce(0) { $0 + $1.minutes }
        let goalProgress = min(1.0, 0.1 + (Double(todayMins) / 120.0) * 0.9)
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // 1. Native Custom Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search books", text: $searchText)
                        Spacer()
                        Image(systemName: "mic.fill")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)

                    // 2. Monthly Challenge Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Monthly Challenge")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                        Text("Read 3 Sci-Fi books this month")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 8)
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: geo.size.width * 0.66, height: 8)
                            }
                        }
                        .frame(height: 8)
                        .padding(.top, 6)
                        
                        HStack {
                            Text("2/3 Books")
                            Spacer()
                            Text("+500 Pts")
                        }
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(colors: [Color.purple.opacity(0.8), Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(24)
                    .shadow(color: Color.indigo.opacity(0.4), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 20)

                    // 3. Stats Grid
                    HStack(spacing: 16) {
                        // Reading Streak
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Reading\nStreak")
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(2)
                                Spacer()
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.orange)
                                    .font(.callout)
                                    .padding(8)
                                    .background(Color.orange.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(vm.readingStreak) Days")
                                    .font(.title2.weight(.bold))
                                Text("Keep it up!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(20)

                        // Total Points
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Total\nPoints")
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(2)
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.callout)
                                    .padding(8)
                                    .background(Color.yellow.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(max(vm.rewardPoints, 1850))")
                                    .font(.title2.weight(.bold))
                                Text("Top 15% of readers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(20)
                    }
                    .padding(.horizontal, 20)

                    // 4. Quick Actions
                    HStack(spacing: 0) {
                        QuickActionView(title: "Scan", icon: "barcode.viewfinder")
                        QuickActionView(title: "Browse", icon: "magnifyingglass")
                        QuickActionView(title: "Halls", icon: "building.2.fill")
                        QuickActionView(title: "Seats", icon: "person.wave.2.fill")
                    }
                    .padding(.horizontal, 10)

                    // 5. Upcoming
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upcoming")
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                UpcomingCardView(icon: "calendar", iconColor: .purple, title: "Room Booking", subtitle: "Today, 12:00")
                                UpcomingCardView(icon: "book.fill", iconColor: .green, title: "Sapiens", subtitle: "Return Tomorrow")
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // 6. Carousels
                    if !vm.activeLoans.isEmpty {
                        SectionCarouselView(title: "Current Reading", books: vm.activeLoans.compactMap { $0.book })
                    }
                    if !vm.featuredBooks.isEmpty {
                        SectionCarouselView(title: "Top Picks", books: vm.featuredBooks)
                        SectionCarouselView(title: "Siri Suggestions", books: vm.featuredBooks.reversed())
                    }

                    // 7. Reading Goals
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Reading Goals")
                            .font(.title3.weight(.bold))
                        
                        VStack(spacing: 24) {
                            ZStack {
                                // Background Track
                                Circle()
                                    .trim(from: 0.1, to: 0.9)
                                    .stroke(Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                    .rotationEffect(.degrees(90))
                                    .frame(width: 220, height: 220)

                                // Progress Fill
                                Circle()
                                    .trim(from: 0.1, to: goalProgress)
                                    .stroke(
                                        LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom),
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(90))
                                    .frame(width: 220, height: 220)
                                    .shadow(color: .purple.opacity(0.5), radius: 8, x: 0, y: 0)
                                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: goalProgress)

                                // Center Text
                                VStack(spacing: 4) {
                                    Text("Today's Reading")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.primary)
                                    Text("\(todayMins / 60):\(String(format: "%02d", todayMins % 60))")
                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .contentTransition(.numericText())
                                    Text("hours : minutes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .offset(y: -10)
                            }
                            .frame(height: 180) // Cliped area for bottom
                            .clipped()

                            VStack(spacing: 12) {
                                Button(action: { showingTracker = true }) {
                                    Text("Keep Reading")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                                }

                                Button(action: { showingHistory = true }) {
                                    Text("Reading History")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.purple.opacity(0.1))
                                        .foregroundColor(.purple)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.purple, .purple.opacity(0.2))
                    }
                }
            }
        }
        .task { await vm.load(user: user, modelContext: modelContext) }
        .sheet(isPresented: $showingTracker) {
            ReadingTrackerView(user: user, activeLoans: vm.activeLoans)
        }
        .sheet(isPresented: $showingHistory) {
            ReadingHistoryView(userId: user.id)
        }
    }
}

// MARK: - Subcomponents

struct QuickActionView: View {
    let title: String
    let icon: String

    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 65, height: 65)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                    .foregroundColor(.primary)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct UpcomingCardView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 50, height: 50)
                .background(iconColor.opacity(0.15))
                .cornerRadius(14)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(width: 240, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

struct SectionCarouselView: View {
    let title: String
    let books: [Book]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.title3.weight(.bold))
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.purple)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(books) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookCoverCard(book: book, width: 110, height: 165)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
