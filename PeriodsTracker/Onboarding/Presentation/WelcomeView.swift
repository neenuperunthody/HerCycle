//
//  WelcomeView.swift
//  PeriodsTracker
//
//  Created by Neenu on 11/10/26.
//

import SwiftUI

struct WelcomeView: View {
    let getStartedAction: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                FloralMark()
                    .accessibilityHidden(true)

                VStack(spacing: 14) {
                    Text("Your cycle, beautifully understood")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.primaryText)
                        .accessibilityAddTraits(.isHeader)

                    Text("Private, gentle period tracking with thoughtful predictions based on the dates you choose to share.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 12) {
                    Button("Get Started", action: getStartedAction)
                        .buttonStyle(LavenderPrimaryButtonStyle())

                    Label("No account required", systemImage: "lock.shield.fill")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer(minLength: 24)
            }
            .frame(maxWidth: 560)
            .padding(.horizontal, AppTheme.horizontalPadding)
            .frame(maxWidth: .infinity)
        }
        .background(AppTheme.background)
        .tint(AppTheme.primaryPurple)
    }
}
