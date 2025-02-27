import SwiftUI
import Combine


final class AddViewModel: ObservableObject {
    
    private let addUseCase: ExerciseListUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var exerciseList: ExerciseListDomain?
    @Published private(set) var isRecordSubmitted = false
    
    @Published var selectedDate = Date()
    @Published var exerciseId: Int = 1
    @Published var exerciseTime: Int = 0
    @Published var minHeartRate: Int = 0
    @Published var maxHeartRate: Int = 0
    @Published var memo: String = ""
    @Published var startTime: Date = Date()
    
    
    @Published var hourText: String = ""
    @Published var minuteText: String = ""
    @Published var isAM: Bool = true
    
    init(addUseCase: ExerciseListUseCaseProtocol) {
        self.addUseCase = addUseCase
    }

    
    func fetchExerciesList() {
        isLoading = true
        error = nil
        
        addUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
            } receiveValue: { [weak self] exercise in
                self?.exerciseList = exercise
                print("exerciseList - \(exercise)")
            }
            .store(in: &cancellables)
    }
    
    func submitExerciseRecord() {
         isLoading = true
         error = nil
         

        let request = AddExerciseRequestDTO(
             userId: 3,
             exerciseId: exerciseId,
             avgBPM: minHeartRate,
             maxBPM: maxHeartRate,
             duration: exerciseTime,
             endAt: selectedDate,
             earnedPoint: calculatePoints(),
             intensity: determineIntensity(),
             note: memo
         )
         addUseCase.executeRecord(request: request)
             .receive(on: DispatchQueue.main)
             .sink { [weak self] completion in
                 self?.isLoading = false
                 switch completion {
                 case .finished:
                     self?.isRecordSubmitted = true
                 case .failure(let error):
                     self?.error = error
                     self?.isRecordSubmitted = false
                 }
             } receiveValue: { _ in
             }
             .store(in: &cancellables)
     }
    
    
    private func calculatePoints() -> Int {
        return 100000
    }
    
    private func determineIntensity() -> String {
        if maxHeartRate > 160 {
            return "힘들어"
        } else if maxHeartRate > 130 {
            return "보통"
        } else {
            return "쉬움"
        }
    }
    
}
