//
//  ViewModel.swift
//  MVVM
//
//  Created by Paramitha on 30/04/24.
//

import Foundation
import Moya
import RxCocoa
import RxMoya
import RxSwift

class ViewModel {
    struct Input {
        let loadDataTrigger: Driver<Void>
        let loadMoreTrigger: Driver<Void>
    }

    let provider = MoyaProvider<NetworkTarget>()
    
    struct Output {
        let data: Driver<[Pokemon]>
        let error: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let currentOffset = BehaviorRelay<Int>(value: 0)
        
        let result = input.loadDataTrigger
            .flatMapLatest { [provider] _ in
                return provider.rx
                    .request(.requestData(limit: 10, offset: currentOffset.value))
                    .asObservable()
                    .mapResult(responseType: Pokemons.self, errorType: NetworkError.self, atKeyPath: "data.pokemons")
                    .asDriver(onErrorDriveWith: .empty())
            }
        
        let data = result.compactMap { result in
            if case .success(let success) = result {
                currentOffset.accept(success.nextOffset)
//                print("wkwk \(success.results)")
                return success.results
            }
            else { return [] }
        }
        
        let error = result.compactMap { result in
            if case .failure(let error) = result {
//                print("wkwk err \(error)")
                return error.localizedDescription
            }
            else { return "Error occured" }
        }
            
        return Output(
            data: data,
            error: error
        )
    }
}
