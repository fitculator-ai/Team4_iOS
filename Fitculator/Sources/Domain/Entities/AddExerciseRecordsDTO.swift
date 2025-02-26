//
//  AddExerciseRecordsDTO.swift
//  Fitculator
//
//  Created by 임재현 on 2/25/25.
//

import Foundation
struct AddExerciseRequestDTO: Codable {
    let userId: Int
    let exerciseId: Int
    let avgBPM: Int
    let maxBPM: Int
    let duration: Int
    let endAt: String 
    let earnedPoint: Int
    let intensity: String
    let note: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case exerciseId = "exercise_id"
        case avgBPM = "avg_bpm"
        case maxBPM = "max_bpm"
        case duration
        case endAt = "end_at"
        case earnedPoint = "earned_point"
        case intensity = "exercise_intensity"
        case note = "exercise_note"
    }
    
    init(userId: Int, exerciseId: Int, avgBPM: Int, maxBPM: Int, duration: Int,
         endAt: Date = Date(), earnedPoint: Int, intensity: String, note: String) {
        self.userId = userId
        self.exerciseId = exerciseId
        self.avgBPM = avgBPM
        self.maxBPM = maxBPM
        self.duration = duration
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.endAt = formatter.string(from: endAt)
        
        self.earnedPoint = earnedPoint
        self.intensity = intensity
        self.note = note
    }
}
