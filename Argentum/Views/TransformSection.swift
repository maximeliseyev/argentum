//
//  TransformSection.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct TransformSection: View {
    @Binding var rotationAngle: Double
    let onRotateLeft: () -> Void
    let onRotateRight: () -> Void

    var body: some View {
        InspectorSection(title: "TRANSFORM") {
            VStack(alignment: .leading, spacing: Spacing.regular) {
                // Rotation controls
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Rotation")
                        .parameterLabel()

                    HStack(spacing: Spacing.small) {
                        Button(action: onRotateLeft) {
                            Image(systemName: "rotate.left")
                                .font(Typography.large)
                        }
                        .buttonStyle(IconButtonStyle())

                        Button(action: onRotateRight) {
                            Image(systemName: "rotate.right")
                                .font(Typography.large)
                        }
                        .buttonStyle(IconButtonStyle())

                        Spacer()

                        Text("\(Int(rotationAngle))°")
                            .font(Typography.regularMono)
                            .foregroundColor(.tertiaryText)
                    }
                }
            }
        }
    }
}
