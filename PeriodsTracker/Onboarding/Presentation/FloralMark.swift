//
//  FlowralUI.swift
//  PeriodsTracker
//
//  Created by Neenu on 11/10/26.
//

import SwiftUI

struct FloralMark: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.card)
                .frame(width: 132, height: 132)

            Image(systemName: "camera.macro")
                .font(.system(.largeTitle, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.primaryPurple)
                .imageScale(.large)
        }
    }
}
