//
//  User.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/18.
//

import Foundation

struct User {
    // init에 쓰려고 임시로 var로 작성함
    var name: String
    var nickName: String
    var gender: Gender
    var profileImage: String?
    var trainingRecords: [TrainingRecord]
    
    enum Gender {
        case M
        case F
    }
    
    init() {
        self.name = "Fitculator"
        self.nickName = "Fitculator"
        self.gender = .M
        self.profileImage = ""
        
        self.trainingRecords = (0...90).compactMap { i in
            
            let calendar = Calendar.current
            let trainingTypes = ["런닝", "수영", "요가", "사이클", "웨이트"]
            let intensities: [TrainingRecord.Intensity] = [.verLow, .low, .normal, .high]
            
            if let trainingDate = calendar.date(byAdding: .day, value: -i, to: Date()) {
                return TrainingRecord(
                    trainingDate: trainingDate,
                    trainingName: trainingTypes.randomElement() ?? "기본 운동",
                    avg_bpm: Int.random(in: 90...150),
                    duration: Int.random(in: 30...120), // 운동 시간 (분)
                    end_at: trainingDate.addingTimeInterval(Double(Int.random(in: 30...120) * 60)), // 시작 + 운동시간
                    training_intensity: intensities.randomElement()!,
                    gained_point: Int.random(in: 10...100),
                    training_detail: "운동 상세 내용 \(i + 1)",
                    max_bpm: Int.random(in: 120...180)
                )
            }
            
            return nil
        }
    }
}

struct TrainingRecord {
    let trainingDate: Date
    let trainingName: String
    var avg_bpm: Int
    let duration: Int
    let end_at: Date
    let training_intensity: Intensity
    let gained_point: Int
    var training_detail: String
    var max_bpm: Int
    
    enum Intensity {
        case verLow
        case low
        case normal
        case high
    }
}
