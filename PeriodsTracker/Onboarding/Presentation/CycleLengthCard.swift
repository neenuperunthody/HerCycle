//
//  CycleLengthCard.swift
//  PeriodsTracker
//
//  Created by Neenu on 11/10/26.
//

import SwiftUI

struct CycleLengthCard: View {
    @Binding var cycleLength: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Typical cycle length", systemImage: "arrow.triangle.2.circlepath")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            Stepper(value: $cycleLength, in: 21...40) {
                Text("\(cycleLength) days")
                    .font(.body.weight(.semibold))
            }
            .accessibilityValue("\(cycleLength) days")
        }
        .lavenderCard()
    }
}
