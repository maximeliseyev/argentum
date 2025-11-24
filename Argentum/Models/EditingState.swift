//
//  EditingState.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import Foundation
import Combine

class EditingState: ObservableObject {
    @Published var rotationAngle: Double = 0.0
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
        jpegQuality = 0.9
    }
}
