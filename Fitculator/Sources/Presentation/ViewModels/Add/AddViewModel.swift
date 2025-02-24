import SwiftUI
import Combine


final class AddViewModel: ObservableObject {
    
    private let addUseCase: ExerciseListUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var exerciseList: ExerciseListDomain?
    
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
    
}
