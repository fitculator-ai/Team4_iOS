import Foundation
import SwiftUI

struct User {
    var name: String
    var nickName: String
    var gender: Gender
    var height: Int
    var birthDate: Date
    var restHR: Int
    var userEmail: String
    var profileImage: String?
    var trainingHistory: [Date: [TrainingRecord]]
    var subscriptionPlan: SubscriptionPlan

    enum Gender: String {
        case M = "남성"
        case F = "여성"
    }
    
    init() {
        self.name = "Fitculator"
        self.nickName = "Fitculator"
        self.gender = .M
        self.height = 175
        self.birthDate = Date()
        self.restHR = 60
        self.userEmail = "test@test.com"
        self.profileImage = nil
        self.trainingHistory = User.generateTrainingHistory()
        self.subscriptionPlan = subscriptionPlans[0]
    }
    
    static func generateTrainingHistory() -> [Date: [TrainingRecord]] {
        var history = [Date: [TrainingRecord]]()
        let calendar = Calendar.current
        let today = Date()
        
        // 최근 15주 동안의 월요일을 구함
        for weekOffset in 0..<35 {
            if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)?.startOfWeek(using: calendar) {
                for dayOffset in 0..<7 {
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
//                        if date.dateToString(includeDay: .fullDay).contains("2024.07") { continue }
                        if date <= today {
                            history[date] = TrainingRecord.generateDummyRecords(for: date) // 과거 데이터
                        } else {
                            history[date] = [TrainingRecord.createEmptyRecord(for: date)] // 미래 데이터는 더미값
                        }
                    }
                }
            }
        }
        
        return history
    }
    
    func getTrainingRecords(for period: RecordPeriod, prev: Bool? = nil) -> [[Date: [TrainingRecord]]] {
        let calendar = Calendar.current
        let today = Date()
        var result: [[Date: [TrainingRecord]]] = []

        var weeksToFetch: Int
        switch period {
        case .oneWeek:
            weeksToFetch = 1
            if let prev = prev {
                weeksToFetch += prev ? 1 : -1
            }
        case .oneMonth:
            weeksToFetch = 4
        case .threeMonth:
            weeksToFetch = 12
        case .all:
            weeksToFetch = 35
        }

        if let thisWeekStart = today.startOfWeek(using: calendar) {
            for weekOffset in 0..<weeksToFetch {
                if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: thisWeekStart) {
                    var weekData: [(Date, [TrainingRecord])] = []

                    for dayOffset in 0..<7 {
                        if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                            let records = trainingHistory[date] ?? [TrainingRecord.createEmptyRecord(for: date)]
                            weekData.append((date, records))
                        }
                    }

                    weekData.sort { $0.0 < $1.0 }
                    result.append(Dictionary(uniqueKeysWithValues: weekData))
                }
            }
        }
        
        if let prev = prev, prev {
            result = [result.last!]
        }
        
        return result.reversed() // 과거 -> 현재 순으로 정렬
    }
    
    func getPrevWeek() -> [[Date: [TrainingRecord]]] {
        self.getTrainingRecords(for: .oneWeek, prev: true)
    }
    
    func getNextWeek() -> [[Date: [TrainingRecord]]] {
        self.getTrainingRecords(for: .oneWeek, prev: false)
    }
}

struct TrainingRecord: Equatable {
    var id = UUID()
    let trainingDate: Date
    let trainingName: String
    var avg_bpm: Int
    let duration: Int
    let end_at: Date
    let training_intensity: Intensity
    let gained_point: Double
    var training_detail: String
    var max_bpm: Int
    var key: String {
        return "\(trainingDate.dateToString(includeDay: .fullDay))-\(trainingName)-\(gained_point)"
    }
    
    enum Intensity {
        case verLow
        case low
        case normal
        case high
    }
    
    static func generateDummyRecords(for date: Date) -> [TrainingRecord] {
        let trainingNames = ["러닝", "싸이클", "수영", "근력운동"]
        var records: [TrainingRecord] = []
        
        let count = Int.random(in: 1...3)
        for _ in 0..<count {
            let trainingName = trainingNames.randomElement()!
            let duration = Int.random(in: 30...120)
            let avg_bpm = Int.random(in: 90...160)
            let max_bpm = avg_bpm + Int.random(in: 5...20)
            let intensity: Intensity = [.verLow, .low, .normal, .high].randomElement()!
//            let gained_point = Double.random(in: 10...100)
            let gained_point = Double.random(in: 10...11)
            
            let record = TrainingRecord(
                trainingDate: date,
                trainingName: trainingName,
                avg_bpm: avg_bpm,
                duration: duration,
                end_at: date.addingTimeInterval(TimeInterval(duration * 60)),
                training_intensity: intensity,
                gained_point: gained_point,
                training_detail: "\(trainingName) for \(duration) minutes",
                max_bpm: max_bpm
            )
            records.append(record)
        }
        return records
    }
    
    static func createEmptyRecord(for date: Date) -> TrainingRecord {
        return TrainingRecord(
            trainingDate: date,
            trainingName: "",
            avg_bpm: 0,
            duration: 0,
            end_at: date,
            training_intensity: .verLow,
            gained_point: 0.0,
            training_detail: "",
            max_bpm: 0
        )
    }
}

enum RecordPeriod {
    case oneWeek
    case oneMonth
    case threeMonth
    case all
}

enum CurrentDateState {
    case thisWeek
    case lastWeek
    case other
}
