//
//  AdjustmentsSection.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct AdjustmentsSection: View {
    @Binding var exposure: Double
    @Binding var contrast: Double
    @Binding var brightness: Double
    @Binding var saturation: Double

    var body: some View {
        InspectorSection(title: "ADJUSTMENTS") {
            VStack(alignment: .leading, spacing: Spacing.regular) {
                // Exposure
                AdjustmentSlider(
                    label: "Exposure",
                    value: $exposure,
                    range: -1.0...1.0,
                    defaultValue: 0.0
                )

                // Contrast
                AdjustmentSlider(
                    label: "Contrast",
                    value: $contrast,
                    range: 0.7...1.3,
                    defaultValue: 1.0
                )

                // Brightness
                AdjustmentSlider(
                    label: "Brightness",
                    value: $brightness,
                    range: -0.3...0.3,
                    defaultValue: 0.0
                )

                // Saturation
                AdjustmentSlider(
                    label: "Saturation",
                    value: $saturation,
                    range: 0.7...1.3,
                    defaultValue: 1.0
                )
            }
        }
    }
}

struct AdjustmentSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let defaultValue: Double

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small - 2) {
            HStack(spacing: Spacing.medium) {
                Text(label)
                    .parameterLabel()

                Spacer()

                Text(String(format: "%.2f", value))
                    .valueLabel()

                // Reset button
                Button(action: { value = defaultValue }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(Typography.tiny)
                        .foregroundColor(.quinaryText)
                }
                .buttonStyle(.plain)
                .opacity(value == defaultValue ? 0 : 1)
            }

            Slider(value: $value, in: range)
                .tint(.accentColor)
                .controlSize(.small)
                .onTapGesture(count: 2) {
                    value = defaultValue
                }
        }
    }
}
