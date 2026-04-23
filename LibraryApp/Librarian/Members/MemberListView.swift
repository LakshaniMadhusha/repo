import SwiftUI
import SwiftData

struct MemberListView: View {
    @Query(filter: #Predicate<AppUser> { $0.roleRaw == "Member" }, sort: \AppUser.name) private var members: [AppUser]

    var body: some View {
        NavigationStack {
            List {
                ForEach(members) { member in
                    NavigationLink {
                        MemberDetailView(member: member)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name)
                                .foregroundColor(.textPrimary)
                            Text(member.email)
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.pageBg)
            .navigationTitle("Members")
        }
    }
}

