//
//  CropToolbar.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 25.11.2025.
//

import SwiftUI

struct CropToolbar: View {
    let onApply: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: Spacing.small) {
            // Cancel button
            Button(action: onCancel) {
                HStack(spacing: Spacing.tiny) {
                    Image(systemName: "xmark")
                        .font(Typography.small)
                    Text("Cancel")
                        .font(Typography.weighted(Typography.regular, .medium))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, Spacing.small + 4)
                .padding(.vertical, Spacing.medium - 3)
                .background(Color.overlayBackground)
                .cornerRadius(CornerRadius.regular)
            }
            .buttonStyle(.plain)

            // Apply button
            Button(action: onApply) {
                HStack(spacing: Spacing.tiny) {
                    Image(systemName: "checkmark")
                        .font(Typography.small)
                    Text("Apply Crop")
                        .font(Typography.weighted(Typography.regular, .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.regular)
                .padding(.vertical, Spacing.medium - 3)
                .background(Color.accentColor)
                .cornerRadius(CornerRadius.regular)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.xlarge)
    }
}
