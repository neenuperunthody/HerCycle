import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 28) {
                FloralMark()
                    .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text("Her Cycle")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)

                    Text("Every cycle matters")
                        .font(.title3)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .multilineTextAlignment(.center)
            .padding(AppTheme.horizontalPadding)
            .accessibilityElement(children: .combine)
        }
    }
}

#Preview {
    SplashView()
}
