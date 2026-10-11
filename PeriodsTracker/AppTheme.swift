import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum AppTheme {
    static let background = adaptiveColor(
        light: RGBColor(red: 0xF7, green: 0xF4, blue: 0xFC),
        dark: RGBColor(red: 0x17, green: 0x12, blue: 0x20)
    )
    static let card = adaptiveColor(
        light: RGBColor(red: 0xE8, green: 0xDF, blue: 0xFA),
        dark: RGBColor(red: 0x2A, green: 0x20, blue: 0x39)
    )
    static let elevatedCard = adaptiveColor(
        light: RGBColor(red: 0xFF, green: 0xFF, blue: 0xFF),
        dark: RGBColor(red: 0x23, green: 0x1B, blue: 0x30)
    )
    static let accent = adaptiveColor(
        light: RGBColor(red: 0xB7, green: 0xA1, blue: 0xE4),
        dark: RGBColor(red: 0xA7, green: 0x8F, blue: 0xE0)
    )
    static let primaryPurple = adaptiveColor(
        light: RGBColor(red: 0x76, green: 0x54, blue: 0xB5),
        dark: RGBColor(red: 0xC0, green: 0xA7, blue: 0xFF)
    )
    static let primaryButtonFill = adaptiveColor(
        light: RGBColor(red: 0x76, green: 0x54, blue: 0xB5),
        dark: RGBColor(red: 0x6D, green: 0x4A, blue: 0xAF)
    )
    static let primaryText = adaptiveColor(
        light: RGBColor(red: 0x35, green: 0x26, blue: 0x4F),
        dark: RGBColor(red: 0xF2, green: 0xEC, blue: 0xFC)
    )
    static let secondaryText = adaptiveColor(
        light: RGBColor(red: 0x66, green: 0x5A, blue: 0x78),
        dark: RGBColor(red: 0xC8, green: 0xBE, blue: 0xD6)
    )
    static let border = adaptiveColor(
        light: RGBColor(red: 0xD7, green: 0xCB, blue: 0xEA),
        dark: RGBColor(red: 0x4A, green: 0x3A, blue: 0x61)
    )
    static let destructive = adaptiveColor(
        light: RGBColor(red: 0xA8, green: 0x31, blue: 0x46),
        dark: RGBColor(red: 0xFF, green: 0x9A, blue: 0xAA)
    )

    static let cardCornerRadius: CGFloat = 24
    static let controlCornerRadius: CGFloat = 16
    static let horizontalPadding: CGFloat = 20
}

private struct RGBColor {
    let red: Int
    let green: Int
    let blue: Int

    var redComponent: CGFloat { CGFloat(red) / 255 }
    var greenComponent: CGFloat { CGFloat(green) / 255 }
    var blueComponent: CGFloat { CGFloat(blue) / 255 }
}

private func adaptiveColor(light: RGBColor, dark: RGBColor) -> Color {
#if canImport(UIKit)
    Color(
        uiColor: UIColor { traits in
            let value = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: value.redComponent,
                green: value.greenComponent,
                blue: value.blueComponent,
                alpha: 1
            )
        }
    )
#elseif canImport(AppKit)
    Color(
        nsColor: NSColor(name: nil) { appearance in
            let bestMatch = appearance.bestMatch(from: [.darkAqua, .aqua])
            let value = bestMatch == .darkAqua ? dark : light
            return NSColor(
                red: value.redComponent,
                green: value.greenComponent,
                blue: value.blueComponent,
                alpha: 1
            )
        }
    )
#else
    Color(
        red: Double(light.red) / 255,
        green: Double(light.green) / 255,
        blue: Double(light.blue) / 255
    )
#endif
}

struct LavenderCardModifier: ViewModifier {
    let fill: Color

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(fill, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .stroke(AppTheme.border, lineWidth: 1)
            }
    }
}

extension View {
    func lavenderCard(fill: Color = AppTheme.elevatedCard) -> some View {
        modifier(LavenderCardModifier(fill: fill))
    }

    func appScreenBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .foregroundStyle(AppTheme.primaryText)
            .tint(AppTheme.primaryPurple)
    }
}

struct LavenderPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, 18)
            .background(
                configuration.isPressed ? AppTheme.primaryButtonFill.opacity(0.82) : AppTheme.primaryButtonFill,
                in: RoundedRectangle(cornerRadius: AppTheme.controlCornerRadius)
            )
    }
}

struct LavenderSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.primaryPurple)
            .frame(minHeight: 44)
            .padding(.horizontal, 16)
            .background(
                configuration.isPressed ? AppTheme.card : AppTheme.elevatedCard,
                in: RoundedRectangle(cornerRadius: AppTheme.controlCornerRadius)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.controlCornerRadius)
                    .stroke(AppTheme.border, lineWidth: 1)
            }
    }
}
