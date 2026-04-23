import SwiftUI
import SwiftData
import Charts

struct RewardsView: View {
    @Query(sort: \Badge.earnedAt, order: .reverse) private var badges: [Badge]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    PointsChart()
                        .lightCard()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Badges")
                            .font(.headline)
                            .foregroundColor(.textPrimary)

                        if badges.isEmpty {
                            Text("Earn badges by reading consistently.")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        } else {
                            ForEach(badges.prefix(8)) { badge in
                                HStack {
                                    Image(systemName: "rosette")
                                        .foregroundColor(.accent)
                                    Text(badge.title)
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    Text(badge.earnedAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    .lightCard()
                }
                .padding(20)
            }
            .background(Color.pageBg.ignoresSafeArea())
            .navigationTitle("Rewards")
        }
    }
}

private struct PointsChart: View {
    struct Point: Identifiable {
        let id = UUID()
        let day: Date
        let points: Int
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Points (last 7 days)")
                .font(.headline)
                .foregroundColor(.textPrimary)

            Chart(points) { p in
                LineMark(
                    x: .value("Day", p.day, unit: .day),
                    y: .value("Points", p.points)
                )
                .foregroundStyle(Color.accent)
                PointMark(
                    x: .value("Day", p.day, unit: .day),
                    y: .value("Points", p.points)
                )
                .foregroundStyle(Color.accent)
            }
            .frame(height: 160)
        }
        .padding(16)
    }

    private var points: [Point] {
        let start = Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now
        return (0..<7).compactMap { i in
            let day = Calendar.current.date(byAdding: .day, value: i, to: start) ?? .now
            return Point(day: day, points: Int.random(in: 120...420))
        }
    }
}

