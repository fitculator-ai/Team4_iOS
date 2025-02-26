import SwiftUI
import Combine


final class AddViewModel: ObservableObject {
    
    private let addUseCase: ExerciseListUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var exerciseList: ExerciseListDomain?
    @Published private(set) var isRecordSubmitted = false
    
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
         
         // AddExerciseRequestDTO 생성
         let request = AddExerciseRequestDTO(
             userId: 3,
             exerciseId: 1,
             avgBPM: 1,
             maxBPM: 1,
             duration: 1,
             endAt: Date(),
             earnedPoint: 1,
             intensity: "힘들어",
             note: "으아아아아아아아아아아아아으아아ㅏ아아아아아아아아아아아아"
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
    
}
