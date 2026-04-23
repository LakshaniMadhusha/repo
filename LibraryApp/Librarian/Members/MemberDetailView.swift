import SwiftUI
import SwiftData

struct MemberDetailView: View {
    let member: AppUser

    @Query private var sessions: [ReadingSession]

    init(member: AppUser) {
        self.member = member
        let memberId = member.id
        _sessions = Query(filter: #Predicate<ReadingSession> { session in
            session.userId == memberId
        }, sort: \ReadingSession.startedAt, order: .reverse)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(member.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    Text(member.email)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .lightCard()

                ReadingMinutesChart(sessions: sessions)
                    .lightCard()
            }
            .padding(20)
        }
        .background(Color.pageBg.ignoresSafeArea())
        .navigationTitle("Member")
        .navigationBarTitleDisplayMode(.inline)
    }
}

