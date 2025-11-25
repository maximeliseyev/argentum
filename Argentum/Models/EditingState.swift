//
//  EditingState.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import Foundation
import Combine

class EditingState: ObservableObject {
    // Transform
    @Published var rotationAngle: Double = 0.0

    // Adjustments
    @Published var exposure: Double = 0.0      // -2.0 to 2.0
    @Published var contrast: Double = 1.0      // 0.0 to 2.0
    @Published var brightness: Double = 0.0    // -1.0 to 1.0
    @Published var saturation: Double = 1.0    // 0.0 to 2.0

    // Export
    @Published var jpegQuality: Double = 0.9

    func rotate90Clockwise() {
        rotationAngle -= 90.0
        if rotationAngle <= -360.0 {
            rotationAngle = 0.0
        }
    }

    func rotate90CounterClockwise() {
        rotationAngle += 90.0
        if rotationAngle >= 360.0 {
            rotationAngle = 0.0
        }
    }

    func reset() {
        rotationAngle = 0.0
        exposure = 0.0
        contrast = 1.0
        brightness = 0.0
        saturation = 1.0
        jpegQuality = 0.9
    }
}
