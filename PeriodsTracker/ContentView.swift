import SwiftData
import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isShowingSplash = true
    @State private var isShowingWelcome = true

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
            } else if hasCompletedOnboarding {
                NavigationStack {
                    DashboardView()
                }
                .tint(AppTheme.primaryPurple)
                .transition(.opacity)
            } else if isShowingWelcome {
                WelcomeView {
                    isShowingWelcome = false
                }
                .transition(.opacity)
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
                .transition(.opacity)
            }
        }
        .task {
            guard isShowingSplash else { return }

            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeOut(duration: 0.35)) {
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PeriodEntry.self, inMemory: true)
}
