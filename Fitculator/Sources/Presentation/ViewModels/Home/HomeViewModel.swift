import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var user: User = User()
    @Published var workoutThisWeekHistory: [ThisWeekTraining] = []
    @Published private var isLoading = false
    @Published private var error: NetworkError?
    @Published var currentWeekState: CurrentDateState = .thisWeek
    
    private let fetchUseCase: UseCase
    private let fetchWorkoutThisWeekHistory: fetchWorkoutThisWeekHistoryUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(fetchUseCase: UseCase, fetchWorkoutThisWeekHistory: fetchWorkoutThisWeekHistoryUseCase) {
        self.fetchUseCase = fetchUseCase
        self.fetchWorkoutThisWeekHistory = fetchWorkoutThisWeekHistory

        fetchUser()
        fetchWorkoutHistory()
    }
    
    func fetchUser() {
        fetchUseCase.execute()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error as? NetworkError
                }
            }, receiveValue: { [weak self] user in
                self?.user = user
            })
            .store(in: &cancellables)
    }
    
    func fetchWorkoutHistory() {
        fetchWorkoutThisWeekHistory.execute()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error as? NetworkError
                }
            }, receiveValue: { [weak self] history in
                self?.workoutThisWeekHistory = history
                print("불러오기 성공: \(String(describing: self?.workoutThisWeekHistory))")
            })
            .store(in: &cancellables)
    }
}
