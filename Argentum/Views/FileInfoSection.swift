//
//  FileInfoSection.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct FileInfoSection: View {
    let fileName: String
    let onClose: () -> Void
    let onOpenNew: () -> Void

    var body: some View {
        InspectorSection(title: "FILE") {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text(fileName)
                    .font(Typography.regularMono)
                    .foregroundColor(.primaryText)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: Spacing.small) {
                    Button(action: onOpenNew) {
                        HStack(spacing: Spacing.tiny) {
                            Image(systemName: "folder")
                                .font(Typography.extraSmall)
                            Text("Open New")
                                .font(Typography.weighted(Typography.small, .medium))
                        }
                    }
                    .buttonStyle(InspectorButtonStyle(prominent: true))

                    Button(action: onClose) {
                        HStack(spacing: Spacing.tiny) {
                            Image(systemName: "xmark")
                                .font(Typography.extraSmall)
                            Text("Close")
                                .font(Typography.weighted(Typography.small, .medium))
                        }
                    }
                    .buttonStyle(InspectorButtonStyle(prominent: false))
                }
            }
        }
    }
}
