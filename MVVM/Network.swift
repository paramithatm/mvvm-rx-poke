//
//  Network.swift
//  MVVM
//
//  Created by Paramitha on 30/04/24.
//

import Foundation
import RxCocoa
import RxSwift
import Moya

enum NetworkTarget {
    case requestData(limit: Int, offset: Int)
}

extension NetworkTarget: TargetType {
    var baseURL: URL {
        return URL(string: "https://graphql-pokeapi.graphcdn.app/")!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var parameters: [String: Any] {
        switch self {
        case let .requestData(limit, offset):
            return [
                "query": """
                query pokemons($limit: Int, $offset: Int, ) {
                  pokemons(limit: $limit, offset: $offset) {
                    count
                    nextOffset
                    results {
                      name
                      image
                    }
                  }
                }
                """,
                "variables": [
                    "limit": limit,
                    "offset": offset
                ]
            ]
        }
    }
    
    var task: Moya.Task {
        .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}

enum NetworkError: Error {
    case noInternet
    case serverError
    case clientError
}

extension ObservableType where Element == Response {
    internal func mapResult<D: Decodable, E: Error>(responseType: D.Type, errorType: E.Type, atKeyPath: String? = nil) -> Observable<Result<D, E>> {
        return flatMap { response -> Observable<D> in
            
            if response.statusCode != 200 {
                // if server return is not appropriate
                return .error(NetworkError.serverError)
            }
            
            do {
                let value = try response.map(responseType, atKeyPath: atKeyPath, using: JSONDecoder())
                
//                print(response)
//                print(value)
                return .just(value)
            } catch {
                // if failed when decoding response
                if let moyaError = error as? MoyaError {
                    return .error(moyaError)
                }
                return .error(NetworkError.clientError)
            }
            
        }.map { value -> Result<D, E> in
                .success(value)
        }
    }
}
