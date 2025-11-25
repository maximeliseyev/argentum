//
//  AppTheme.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

// MARK: - Spacing

enum Spacing {
    static let tiny: CGFloat = 3
    static let small: CGFloat = 6
    static let medium: CGFloat = 8
    static let regular: CGFloat = 12
    static let large: CGFloat = 14
    static let xlarge: CGFloat = 16
    static let xxlarge: CGFloat = 20
    static let xxxlarge: CGFloat = 24
}

// MARK: - Corner Radius

enum CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 5
    static let regular: CGFloat = 6
}

// MARK: - Sizing

enum Sizing {
    enum Button {
        static let smallHeight: CGFloat = 26
        static let regularHeight: CGFloat = 32
        static let smallWidth: CGFloat = 36
        static let regularWidth: CGFloat = 44
    }

    enum Panel {
        static let inspectorWidth: CGFloat = 280
        static let viewerMinWidth: CGFloat = 500
    }
}

// MARK: - Colors

extension Color {
    static let appBackground = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let panelBackground = Color(red: 0.12, green: 0.12, blue: 0.12)

    static let primaryText = Color.white.opacity(0.9)
    static let secondaryText = Color.white.opacity(0.7)
    static let tertiaryText = Color.white.opacity(0.6)
    static let quaternaryText = Color.white.opacity(0.5)
    static let quinaryText = Color.white.opacity(0.4)

    static let buttonBackground = Color.white.opacity(0.1)
    static let buttonBackgroundSubtle = Color.white.opacity(0.05)
    static let overlayBackground = Color.black.opacity(0.3)
}

// MARK: - Typography

enum Typography {
    static let tiny = Font.system(size: 8)
    static let extraSmall = Font.system(size: 9)
    static let small = Font.system(size: 10)
    static let regular = Font.system(size: 11)
    static let medium = Font.system(size: 12)
    static let large = Font.system(size: 13)

    static let tinyMono = Font.system(size: 8, design: .monospaced)
    static let extraSmallMono = Font.system(size: 9, design: .monospaced)
    static let smallMono = Font.system(size: 10, design: .monospaced)
    static let regularMono = Font.system(size: 11, design: .monospaced)
    static let mediumMono = Font.system(size: 12, design: .monospaced)

    static func weighted(_ font: Font, _ weight: Font.Weight) -> Font {
        return font.weight(weight)
    }
}

// MARK: - Animation

enum Animation {
    static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
    static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
}
