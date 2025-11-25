//
//  ExportSection.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct ExportSection: View {
    @Binding var jpegQuality: Double
    let isEnabled: Bool
    let onExport: () -> Void

    var body: some View {
        InspectorSection(title: "EXPORT") {
            VStack(alignment: .leading, spacing: Spacing.regular) {
                // JPEG Quality
                VStack(alignment: .leading, spacing: Spacing.small - 2) {
                    HStack(spacing: Spacing.medium) {
                        Text("Quality")
                            .parameterLabel()

                        Spacer()

                        Text("\(Int(jpegQuality * 100))%")
                            .valueLabel()
                    }

                    Slider(value: $jpegQuality, in: 0.5...1.0)
                        .tint(.accentColor)
                        .controlSize(.small)
                        .onTapGesture(count: 2) {
                            jpegQuality = 0.9
                        }
                }

                // Export button
                Button(action: onExport) {
                    HStack(spacing: Spacing.small) {
                        Image(systemName: "square.and.arrow.down")
                            .font(Typography.medium)
                        Text("Export JPEG")
                            .font(Typography.weighted(Typography.medium, .medium))
                    }
                }
                .buttonStyle(ExportButtonStyle(isEnabled: isEnabled))
                .disabled(!isEnabled)
            }
        }
    }
}
