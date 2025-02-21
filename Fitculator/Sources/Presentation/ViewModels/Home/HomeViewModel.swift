import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var user: User = User()
    @Published var errorMessage: String? = nil
    @Published var currentWeekState: CurrentDateState = .thisWeek
    
    private let fetchUseCase: UseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(fetchUseCase: UseCase) {
        self.fetchUseCase = fetchUseCase
        fetchUser()
    }
    
    func fetchUser() {
        fetchUseCase.execute()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] user in
                self?.user = user
            })
            .store(in: &cancellables)
    }
    
    func getPrevWeek() -> [[Date: [TrainingRecord]]] {
        user.getTrainingRecords(for: .oneWeek, prev: true)
    }
    
    func getNextWeek() -> [[Date: [TrainingRecord]]] {
        user.getTrainingRecords(for: .oneWeek, prev: false)
    }
}
