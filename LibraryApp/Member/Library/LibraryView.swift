import SwiftUI
import SwiftData

struct LibraryView: View {
    @EnvironmentObject var auth: AuthService
    let user: AppUser

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Quick Actions Grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.title3.weight(.bold))

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            NavigationLink(destination: LoansView(userId: user.id)) {
                                LibraryActionCard(
                                    title: "My Loans",
                                    subtitle: "View & manage borrowed books",
                                    icon: "book.fill",
                                    color: .blue
                                )
                            }

                            NavigationLink(destination: ReadingProgressView(user: user)) {
                                LibraryActionCard(
                                    title: "Reading Progress",
                                    subtitle: "Track your reading journey",
                                    icon: "chart.bar.fill",
                                    color: .green
                                )
                            }

                            NavigationLink(destination: ReadingTrackerView(user: user, activeLoans: [])) {
                                LibraryActionCard(
                                    title: "Reading Tracker",
                                    subtitle: "Log reading sessions",
                                    icon: "timer",
                                    color: .orange
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Library Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Library Overview")
                            .font(.title3.weight(.bold))

                        HStack(spacing: 16) {
                            LibraryStatCard(
                                title: "Books Available",
                                value: "1,247",
                                icon: "books.vertical.fill",
                                color: .blue
                            )
                            LibraryStatCard(
                                title: "Seats Available",
                                value: "23/45",
                                icon: "person.2.fill",
                                color: .purple
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Recent Activity
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Activity")
                            .font(.title3.weight(.bold))

                        VStack(spacing: 12) {
                            ActivityRow(
                                title: "Returned 'The Great Gatsby'",
                                subtitle: "2 hours ago",
                                icon: "arrowshape.turn.up.left.fill",
                                color: .green
                            )
                            ActivityRow(
                                title: "Reserved study room A-101",
                                subtitle: "1 day ago",
                                icon: "calendar.badge.plus",
                                color: .purple
                            )
                            ActivityRow(
                                title: "Completed reading goal",
                                subtitle: "3 days ago",
                                icon: "checkmark.circle.fill",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("My Library")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LibraryActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct LibraryStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.subheadline)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

