//
//  PeriodDurationCard.swift
//  PeriodsTracker
//
//  Created by Neenu on 11/10/26.
//

import SwiftUI

struct PeriodDurationCard: View {
    @Binding var includesPeriodDuration: Bool
    @Binding var periodDuration: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Add typical period duration", isOn: $includesPeriodDuration)
                .font(.headline)
                .tint(AppTheme.primaryPurple)

            if includesPeriodDuration {
                Stepper(value: $periodDuration, in: 2...10) {
                    Text("\(periodDuration) days")
                        .font(.body.weight(.semibold))
                }
                .accessibilityValue("\(periodDuration) days")
            } else {
                Text("Optional — we’ll use a 5-day starting estimate.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .lavenderCard()
    }
}
