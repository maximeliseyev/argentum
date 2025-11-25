//
//  InspectorSection.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct InspectorSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            Text(title)
                .sectionTitle()

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
