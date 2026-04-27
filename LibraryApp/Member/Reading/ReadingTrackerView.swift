import SwiftUI
import SwiftData

struct ReadingTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let user: AppUser
    let activeLoans: [Loan]
    
    @State private var selectedBook: Book?
    @State private var timeElapsed: TimeInterval = 0
    @State private var isRunning = false
    @State private var timerTask: Task<Void, Never>?
    @State private var lastTickDate = Date()
    @State private var showSuccess = false
    @State private var targetMinutes: Double = 15
    @State private var isManualMode = false
    @State private var manualDate = Date()
    @State private var manualMinutes: Int = 30
    
    // Integrated Reader Features
    @State private var isReadingMode = false
    @State private var targetReached = false
    
    init(user: AppUser, activeLoans: [Loan], preSelectedBook: Book? = nil) {
        self.user = user
        self.activeLoans = activeLoans
        self._selectedBook = State(initialValue: preSelectedBook)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isReadingMode, let url = URL(string: selectedBook?.pdfUrl ?? "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf") {
                    // Reader Mode UI (PDF Viewer) - NO ScrollView here to prevent gesture conflicts
                    EBookWebView(url: url)
                        .edgesIgnoringSafeArea(.bottom)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Tracker UI with ScrollView for responsiveness
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            Picker("Tracking Mode", selection: $isManualMode) {
                                Text("Live Timer").tag(false)
                                Text("Manual Log").tag(true)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            
                            // Book Selection
                            if activeLoans.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "books.vertical.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                    Text("No active loans.")
                                        .font(.headline)
                                    Text("Borrow a book to start tracking your reading.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(16)
                                .padding(.horizontal, 20)
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("What are you reading?")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 24)
                                    
                                    Picker("Select Book", selection: $selectedBook) {
                                        Text("Select a book...").tag(Book?.none)
                                        ForEach(activeLoans.compactMap { $0.book }) { book in
                                            Text(book.title).tag(Book?.some(book))
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(16)
                                    .padding(.horizontal, 20)
                                }
                                
                                if !isManualMode {
                                    // Target Selection
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Reading Target")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("\(Int(targetMinutes)) min")
                                                .font(.subheadline.weight(.bold))
                                                .foregroundColor(.purple)
                                        }
                                        .padding(.horizontal, 24)
                                        
                                        Slider(value: $targetMinutes, in: 5...120, step: 5)
                                            .tint(.purple)
                                            .padding(.horizontal, 24)
                                    }
                                }
                            }
                            
                            if !isManualMode {
                                // Clock Area
                                ZStack {
                                    Circle()
                                        .stroke(
                                            LinearGradient(colors: [.purple.opacity(0.2), .indigo.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            lineWidth: 24
                                        )
                                    
                                    Circle()
                                        .trim(from: 0, to: CGFloat(min(1.0, timeElapsed / (targetMinutes * 60))))
                                        .stroke(
                                            LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom),
                                            style: StrokeStyle(lineWidth: 24, lineCap: .round)
                                        )
                                        .rotationEffect(.degrees(-90))
                                        .animation(.linear(duration: 1.0), value: timeElapsed)
                                    
                                    VStack {
                                        let minutes = Int(timeElapsed) / 60
                                        let seconds = Int(timeElapsed) % 60
                                        Text("\(minutes):\(String(format: "%02d", seconds))")
                                            .font(.system(size: 64, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                            .contentTransition(.numericText())
                                        Text("Minutes Read")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(width: 280, height: 280)
                                .padding(.top, 20)
                                
                                Spacer()
                                
                                // Controls
                                if selectedBook != nil || timeElapsed > 0 || !activeLoans.isEmpty {
                                    HStack(spacing: 20) {
                                        if !isRunning && timeElapsed == 0 {
                                            Button(action: startTimer) {
                                                Image(systemName: "play.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(.white)
                                                    .frame(width: 80, height: 80)
                                                    .background(LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom))
                                                    .clipShape(Circle())
                                                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                                            }
                                        } else {
                                            Button(action: isRunning ? pauseTimer : startTimer) {
                                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(.white)
                                                    .frame(width: 80, height: 80)
                                                    .background(isRunning ? Color.orange : Color.green)
                                                    .clipShape(Circle())
                                                    .shadow(color: (isRunning ? Color.orange : Color.green).opacity(0.4), radius: 10, x: 0, y: 5)
                                            }
                                            
                                            Button(action: saveSession) {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 32, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: 80, height: 80)
                                                    .background(Color.purple)
                                                    .clipShape(Circle())
                                                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                                            }
                                        }
                                    }
                                    .padding(.bottom, 40)
                                }
                            } else {
                                // Manual Log Area
                                VStack(spacing: 32) {
                                    DatePicker("Date Read", selection: $manualDate, in: ...Date(), displayedComponents: .date)
                                        .font(.headline)
                                        .padding(.horizontal, 24)
                                    
                                    Stepper("Time Read: \(manualMinutes) mins", value: $manualMinutes, in: 1...600, step: 5)
                                        .font(.headline)
                                        .padding(.horizontal, 24)
                                    
                                    Button(action: saveManualSession) {
                                        Text("Save Entry")
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
                                    .padding(.horizontal, 24)
                                    .padding(.top, 24)
                                }
                                .padding(.top, 40)
                                
                                Spacer()
                            }
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Reading Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        pauseTimer()
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
            .overlay {
                if showSuccess {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.green)
                        Text("Reading Logged!")
                            .font(.title2.weight(.bold))
                        Text("+\(isManualMode ? manualMinutes * 10 : max(1, Int(timeElapsed) / 60) * 10) Pts")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                    .padding(32)
                    .background(.regularMaterial)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .overlay(alignment: .bottomTrailing) {
                // Reader Toggle Button
                if !isManualMode && selectedBook != nil {
                    Button(action: { withAnimation(.spring()) { isReadingMode.toggle() }}) {
                        HStack(spacing: 8) {
                            Image(systemName: isReadingMode ? "clock.fill" : "book.pages.fill")
                            Text(isReadingMode ? "Focus Mode" : "Reader Mode")
                                .font(.subheadline.weight(.bold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.purpleAccent)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(24)
                    .padding(.bottom, isReadingMode ? 40 : 0)
                }
            }
            .overlay(alignment: .top) {
                // Floating Timer for Reader Mode
                if isReadingMode {
                    HStack(spacing: 12) {
                        Image(systemName: "timer")
                            .foregroundColor(.purpleAccent)
                        
                        let minutes = Int(timeElapsed) / 60
                        let seconds = Int(timeElapsed) % 60
                        Text("\(minutes):\(String(format: "%02d", seconds))")
                            .font(.system(.body, design: .rounded).weight(.bold))
                        
                        Divider().frame(height: 16)
                        
                        Text("\(Int(targetMinutes))m Target")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.purpleAccent.opacity(0.2), lineWidth: 1))
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            if selectedBook != nil && !isRunning {
                startTimer()
            }
        }
        .onDisappear {
            pauseTimer()
        }
    }
    
    private func startTimer() {
        isRunning = true
        lastTickDate = Date()
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { break }
                let now = Date()
                let elapsedSinceTick = now.timeIntervalSince(lastTickDate)
                lastTickDate = now
                withAnimation(.linear(duration: 1.0)) {
                    timeElapsed += elapsedSinceTick
                }
                
                // Auto-award points on target completion
                if !targetReached && timeElapsed >= (targetMinutes * 60) {
                    targetReached = true
                    Task { @MainActor in
                        triggerTargetReachedSuccess()
                    }
                }
            }
        }
    }
    
    private func triggerTargetReachedSuccess() {
        // Auto-save a milestone session
        let session = ReadingSession(minutes: Int(targetMinutes), userId: user.id)
        session.book = selectedBook
        session.challengeName = "Daily Goal Reached"
        session.challengeBonus = 50
        modelContext.insert(session)
        try? modelContext.save()
        
        triggerSuccess()
    }
    
    private func pauseTimer() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }
    
    private func saveSession() {
        pauseTimer()
        let minutes = max(1, Int(timeElapsed) / 60)
        
        let session = ReadingSession(minutes: minutes, userId: user.id)
        session.book = selectedBook
        modelContext.insert(session)
        try? modelContext.save()
        
        // Schedule challenge milestone notification
        NotificationService.shared.scheduleChallengeMilestone(userId: user.id, milestone: "Read for \(minutes) minutes!")
        
        triggerSuccess()
    }
    
    private func saveManualSession() {
        let session = ReadingSession(startedAt: manualDate, minutes: manualMinutes, userId: user.id)
        session.book = selectedBook
        modelContext.insert(session)
        try? modelContext.save()
        
        triggerSuccess()
    }
    
    private func triggerSuccess() {
        withAnimation(.spring()) {
            showSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
