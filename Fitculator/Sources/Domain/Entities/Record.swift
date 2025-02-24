//
//  Record.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/24.
//

import Foundation

struct Record: Codable, Equatable {
    let user_id: Int
    let exercise_name: String
    let avg_bpm, max_bpm, duration: Int
    let end_at: String
    let exercise_intensity: Intensity
    let earned_point: Double
    let exercise_note: String?
}
