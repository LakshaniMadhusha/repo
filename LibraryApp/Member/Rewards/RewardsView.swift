import SwiftUI
import SwiftData
import Charts

struct RewardsView: View {
    @Query(sort: \Badge.earnedAt, order: .reverse) private var badges: [Badge]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // 1. Total Points Header Banner
                    HStack(spacing: 20) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Balance")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("1,850")
                                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Pts")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        Spacer()
                    }
                    .padding(24)
                    .background(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(28)
                    .shadow(color: .purple.opacity(0.4), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // 2. Interactive Premium Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reading Activity")
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 20)
                        
                        PremiumPointsChart()
                            .padding(20)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                            .padding(.horizontal, 20)
                    }

                    // 3. Earn More Points (Suggestions)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ways to Earn Points")
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            SuggestionRow(icon: "book.pages.fill", color: .blue, title: "Read 3 fiction books", points: "+150 Pts", subtitle: "Weekly challenge entirely based on fiction.")
                            SuggestionRow(icon: "star.bubble.fill", color: .orange, title: "Review a recently read book", points: "+50 Pts", subtitle: "Help the community with your feedback.")
                            SuggestionRow(icon: "flame.fill", color: .red, title: "Maintain a 7-day reading streak", points: "+200 Pts", subtitle: "Read at least a few pages every day for a week.")
                        }
                        .padding(.horizontal, 20)
                    }

                    // 4. Badges & Achievements
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Badges")
                                .font(.title3.weight(.bold))
                            Spacer()
                            Button("See All") {}
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.purple)
                        }
                        .padding(.horizontal, 20)

                        if badges.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "medal.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("No badges yet")
                                    .font(.headline)
                                Text("Complete reading challenges to earn badges.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(32)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(24)
                            .padding(.horizontal, 20)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(badges.prefix(5)) { badge in
                                        BadgeCard(badge: badge)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Rewards")
        }
    }
}

// MARK: - Subcomponents

struct PremiumPointsChart: View {
    struct Point: Identifiable {
        let id = UUID()
        let day: Date
        let points: Int
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LAST 7 DAYS")
                .font(.caption2.weight(.bold))
                .foregroundColor(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("1,240")
                    .font(.title.weight(.bold))
                Text("Pts Total")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Chart(points) { p in
                AreaMark(
                    x: .value("Day", p.day, unit: .day),
                    y: .value("Points", p.points)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple.opacity(0.4), .purple.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Day", p.day, unit: .day),
                    y: .value("Points", p.points)
                )
                .foregroundStyle(Color.purple)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                PointMark(
                    x: .value("Day", p.day, unit: .day),
                    y: .value("Points", p.points)
                )
                .foregroundStyle(Color.purple)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine().foregroundStyle(.clear)
                    AxisValueLabel(format: .dateTime.weekday(.short))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(Color.secondary.opacity(0.2))
                    AxisValueLabel()
                }
            }
            .padding(.top, 16)
        }
    }

    private var points: [Point] {
        let start = Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now
        return (0..<7).compactMap { i in
            let day = Calendar.current.date(byAdding: .day, value: i, to: start) ?? .now
            return Point(day: day, points: Int.random(in: 120...420))
        }
    }
}

struct SuggestionRow: View {
    let icon: String
    let color: Color
    let title: String
    let points: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15))
                .cornerRadius(14)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    Spacer()
                    Text(points)
                        .font(.caption.weight(.bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
    }
}

struct BadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.indigo.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: "medal.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .purple.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            VStack(spacing: 4) {
                Text(badge.title)
                    .font(.caption.weight(.bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.earnedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 110)
        .padding(.vertical, 16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}
