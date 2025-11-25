//
//  CropSection.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct CropSection: View {
    @Binding var isCropActive: Bool
    @Binding var aspectRatio: CropAspectRatio
    @Binding var customWidth: String
    @Binding var customHeight: String

    var body: some View {
        InspectorSection(title: "CROP") {
            VStack(alignment: .leading, spacing: Spacing.regular) {
                // Start/Stop crop button
                Button(action: { isCropActive.toggle() }) {
                    HStack(spacing: Spacing.small) {
                        Image(systemName: isCropActive ? "xmark" : "crop")
                            .font(Typography.medium)
                        Text(isCropActive ? "Cancel Crop" : "Start Cropping")
                            .font(Typography.weighted(Typography.medium, .medium))
                    }
                }
                .buttonStyle(ExportButtonStyle(isEnabled: true))

                if isCropActive {
                    // Aspect ratio selector
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Aspect Ratio")
                            .parameterLabel()

                        // Quick aspect ratio buttons
                        HStack(spacing: Spacing.small) {
                            AspectRatioButton(
                                title: "Free",
                                isSelected: aspectRatio == .free,
                                action: { aspectRatio = .free }
                            )

                            AspectRatioButton(
                                title: "Original",
                                isSelected: aspectRatio == .original,
                                action: { aspectRatio = .original }
                            )
                        }

                        // Custom aspect ratio
                        VStack(alignment: .leading, spacing: Spacing.small - 2) {
                            HStack(spacing: Spacing.small) {
                                TextField("W", text: $customWidth)
                                    .textFieldStyle(.plain)
                                    .font(Typography.regularMono)
                                    .foregroundColor(.primaryText)
                                    .frame(width: 50)
                                    .padding(Spacing.small)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(CornerRadius.small)
                                    .onChange(of: customWidth) { _, _ in
                                        updateCustomAspectRatio()
                                    }

                                Text(":")
                                    .font(Typography.regular)
                                    .foregroundColor(.tertiaryText)

                                TextField("H", text: $customHeight)
                                    .textFieldStyle(.plain)
                                    .font(Typography.regularMono)
                                    .foregroundColor(.primaryText)
                                    .frame(width: 50)
                                    .padding(Spacing.small)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(CornerRadius.small)
                                    .onChange(of: customHeight) { _, _ in
                                        updateCustomAspectRatio()
                                    }

                                Button(action: applyCustomRatio) {
                                    Image(systemName: "checkmark")
                                        .font(Typography.small)
                                        .foregroundColor(.secondaryText)
                                        .frame(width: 28, height: 28)
                                        .background(Color.buttonBackground)
                                        .cornerRadius(CornerRadius.small)
                                }
                                .buttonStyle(.plain)
                            }

                            if case .custom(let w, let h) = aspectRatio {
                                Text("Custom: \(Int(w)):\(Int(h))")
                                    .font(Typography.extraSmall)
                                    .foregroundColor(.tertiaryText)
                            }
                        }
                    }
                }
            }
        }
    }

    private func updateCustomAspectRatio() {
        // This will be triggered by text field changes
        // The actual application happens when user clicks checkmark
    }

    private func applyCustomRatio() {
        guard let width = Double(customWidth),
              let height = Double(customHeight),
              width > 0, height > 0 else {
            return
        }
        aspectRatio = .custom(width: width, height: height)
    }
}

struct AspectRatioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.weighted(Typography.small, .medium))
                .foregroundColor(isSelected ? .white : .tertiaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.small)
                .background(isSelected ? Color.accentColor : Color.buttonBackground)
                .cornerRadius(CornerRadius.small)
        }
        .buttonStyle(.plain)
    }
}
