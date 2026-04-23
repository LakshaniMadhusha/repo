import SwiftUI
import SwiftData

struct AppRouter: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showSplash: Bool = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .task {
                        auth.bootstrap(modelContext: modelContext)
                        // Give the splash screen animation time to play out
                        try? await Task.sleep(for: .seconds(2.5))
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
            } else {
                switch auth.state {
                case .signedOut:
                    AuthEntryView()
                        .transition(.opacity)
                case .signedIn(let user):
                    if auth.isAppLocked {
                        AppLockView()
                    } else {
                        if user.role == .member {
                            MemberTabView(user: user)
                        } else {
                            LibrarianTabView(user: user)
                        }
                    }
                }
            }
        }
        .background(Color.pageBg.ignoresSafeArea())
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                auth.didEnterBackground()
            case .active:
                auth.willEnterForeground()
            default:
                break
            }
        }
    }
}

