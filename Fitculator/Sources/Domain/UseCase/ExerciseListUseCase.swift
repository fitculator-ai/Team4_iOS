//
//  ExerciseListUseCase.swift
//  Fitculator
//
//  Created by 임재현 on 2/24/25.
//

import Combine

protocol ExerciseListUseCaseProtocol {
    func execute() -> AnyPublisher<ExerciseListDomain, NetworkError>
}

class ExerciseListUseCase: ExerciseListUseCaseProtocol {
   private let repository: ExerciseListRepositoryProtocol
   
   init(repository: ExerciseListRepositoryProtocol) {
       self.repository = repository
   }
   
    func execute() -> AnyPublisher<ExerciseListDomain, NetworkError> {
        return repository.fetchExerciseList()
           .mapError { $0 as NetworkError }
           .eraseToAnyPublisher()
   }
}
