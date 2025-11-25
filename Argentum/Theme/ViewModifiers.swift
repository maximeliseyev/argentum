//
//  ViewModifiers.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

// MARK: - Label Styles

struct SectionTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Typography.weighted(Typography.extraSmall, .semibold))
            .foregroundColor(.quinaryText)
            .tracking(1.5)
    }
}

struct ParameterLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Typography.weighted(Typography.small, .medium))
            .foregroundColor(.quaternaryText)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

struct ValueLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Typography.smallMono)
            .foregroundColor(.tertiaryText)
    }
}

// MARK: - Button Styles

struct InspectorButtonStyle: ButtonStyle {
    let prominent: Bool

    init(prominent: Bool = false) {
        self.prominent = prominent
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(prominent ? .secondaryText : .tertiaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.medium - 3)
            .background(prominent ? Color.buttonBackground : Color.buttonBackgroundSubtle)
            .cornerRadius(CornerRadius.small)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.secondaryText)
            .frame(width: Sizing.Button.smallWidth, height: Sizing.Button.smallHeight)
            .background(Color.buttonBackground)
            .cornerRadius(CornerRadius.medium)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct ExportButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.medium - 4)
            .background(isEnabled ? Color.accentColor : Color.buttonBackground)
            .cornerRadius(CornerRadius.regular)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - View Extensions

extension View {
    func sectionTitle() -> some View {
        modifier(SectionTitleModifier())
    }

    func parameterLabel() -> some View {
        modifier(ParameterLabelModifier())
    }

    func valueLabel() -> some View {
        modifier(ValueLabelModifier())
    }
}
