import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.modelContext) private var modelContext
    let user: AppUser
    
    @Query private var sessions: [ReadingSession]
    @Query private var allNotifications: [AppNotification]
    
    @State private var showingNotifications = false
    @State private var showingGoalSetter = false
    
    // Settings state
    @State private var biometricToggle: Bool = false
    @AppStorage("pushNotificationsEnabled") private var pushNotificationsEnabled = true
    @AppStorage("includePDFsEnabled") private var includePDFsEnabled = true
    @AppStorage("dynamicTypeEnabled") private var dynamicTypeEnabled = false
    @AppStorage("voiceOverSupport") private var voiceOverSupport = false
    
    init(user: AppUser) {
        self.user = user
        let userId = user.id
        self._sessions = Query(
            filter: #Predicate<ReadingSession> { $0.userId == userId },
            sort: [SortDescriptor(\.startedAt, order: .reverse)]
        )
    }
    
    var unreadCount: Int {
        allNotifications.filter { ($0.userId == user.id || $0.userId == nil) && !$0.isRead }.count
    }
    
    // Calculate stats
    var booksRead: Int {
        Set(sessions.compactMap { $0.book?.id }).count
    }
    
    var totalPoints: Int {
        sessions.reduce(0) { $0 + ($1.minutes / 10) + $1.challengeBonus }
    }
    
    var dayStreak: Int {
        if sessions.isEmpty { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) })
        let sortedDays = uniqueDays.sorted(by: >)
        if sortedDays.first.map({ !calendar.isDateInToday($0) }) ?? true { return 0 }
        var streak = 1
        for i in 1..<sortedDays.count {
            let expected = calendar.date(byAdding: .day, value: -i, to: sortedDays[0])!
            if sortedDays[i] == expected { streak += 1 } else { break }
        }
        return streak
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageBg.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // 1. Header
                        headerView
                        
                        // 2. Membership Card
                        membershipCard
                        
                        // 3. Stats Strip
                        statsStrip
                        
                        // 4. Earned Badges
                        earnedBadgesSection
                        
                        // 5. Settings Blocks
                        settingsSection
                        
                        // 6. Accessibility Block
                        accessibilitySection
                        
                        // 7. Log Out Button
                        logOutButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingNotifications) {
                NotificationsView(userId: user.id)
            }
            .onAppear {
                biometricToggle = user.isBiometricEnabled
            }
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack {
            Text("Profile")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(.textPrimary)
            Spacer()
            
            Button(action: { showingNotifications = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(.textPrimary)
                    
                    if unreadCount > 0 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: -2)
                    }
                }
            }
            .padding(.trailing, 16)
            
            Circle()
                .fill(Color.surfaceBg)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(user.name.prefix(1))
                        .font(.headline.weight(.bold))
                        .foregroundColor(.accent)
                )
        }
    }
    
    private var membershipCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Library Companion")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                    Text("Digital Membership")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                    Text("ID : \(user.membershipId ?? "9845 1045 7654")")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.white.opacity(0.8))
                    Text("Membership since \(Calendar.current.component(.year, from: user.createdAt))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 160)
            .background(
                LinearGradient(colors: [.accent, .purpleAccent], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            
            // Cutout
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceBg)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(user.name.prefix(1))
                            .font(.title2.weight(.bold))
                            .foregroundColor(.accent)
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.pageBg)
            )
            .offset(x: 10, y: -10)
        }
    }
    
    private var statsStrip: some View {
        HStack {
            StatItem(value: "\(booksRead)", label: "Books Read")
            Divider().frame(height: 40)
            StatItem(value: "\(totalPoints)", label: "Points")
            Divider().frame(height: 40)
            StatItem(value: "\(dayStreak)", label: "Day Streak")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.cardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var earnedBadgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Earned Badges")
                .font(.headline.weight(.bold))
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ProfileBadgeCard(title: "Speed\nReader", icon: "bolt.fill", iconColor: .yellow)
                ProfileBadgeCard(title: "Book\nWorm", icon: "books.vertical.fill", iconColor: .cyan)
                ProfileBadgeCard(title: "Quiz\nMaster", icon: "target", iconColor: .red)
                ProfileBadgeCard(title: "Early\nBird", icon: "sun.max.fill", iconColor: .orange)
                ProfileBadgeCard(title: "Night\nOwl", icon: "moon.stars.fill", iconColor: .purple)
                ProfileBadgeCard(title: "Genre\nExplore", icon: "book.fill", iconColor: .green)
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 0) {
            SettingsToggleRow(title: "Push Notifications", icon: "bell.fill", bgColor: .red, isOn: $pushNotificationsEnabled)
            Divider().background(Color.divider).padding(.leading, 56)
            
            SettingsToggleRow(title: "Face ID / Touch ID", icon: "faceid", bgColor: .green, isOn: $biometricToggle)
                .onChange(of: biometricToggle) { _, newValue in
                    auth.setBiometricEnabled(newValue, for: user, modelContext: modelContext)
                }
            Divider().background(Color.divider).padding(.leading, 56)
            
            SettingsToggleRow(title: "Include PDFs", icon: "doc.fill", bgColor: .red, isOn: $includePDFsEnabled)
            Divider().background(Color.divider).padding(.leading, 56)
            
            Button(action: { showingGoalSetter = true }) {
                SettingsNavigationRow(title: "Reading Goal (5 / mo)", icon: "gearshape.fill", bgColor: .gray)
            }
            .sheet(isPresented: $showingGoalSetter) {
                // A quick goal setter fallback
                Text("Reading Goal Setup").font(.title).presentationDetents([.medium])
            }
            
            if user.role == .librarian {
                Divider().background(Color.divider).padding(.leading, 56)
                NavigationLink(destination: Text("Librarian Dashboard Placeholder")) {
                    SettingsNavigationRow(title: "Librarian Dashboard", icon: "person.2.badge.gearshape.fill", bgColor: .blue)
                }
            }
        }
        .background(Color.cardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var accessibilitySection: some View {
        VStack(spacing: 0) {
            SettingsToggleRow(title: "Dynamic Type", icon: "textformat.size", bgColor: .cyan, isOn: $dynamicTypeEnabled)
            Divider().background(Color.divider).padding(.leading, 56)
            SettingsToggleRow(title: "VoiceOver Support", icon: "speaker.wave.3.fill", bgColor: .purple, isOn: $voiceOverSupport)
        }
        .background(Color.cardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var logOutButton: some View {
        Button(action: { auth.signOut() }) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
                Text("Log Out")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.cardBg)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Subcomponents

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.heavy))
                .foregroundColor(.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileBadgeCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accent.opacity(0.3), lineWidth: 1.5)
        )
    }
}

struct SettingsToggleRow: View {
    let title: String
    let icon: String
    let bgColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(bgColor)
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.caption)
            }
            Text(title)
                .font(.subheadline)
                .foregroundColor(.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsNavigationRow: View {
    let title: String
    let icon: String
    let bgColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(bgColor)
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.caption)
            }
            Text(title)
                .font(.subheadline)
                .foregroundColor(.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.textSecondary)
                .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}
