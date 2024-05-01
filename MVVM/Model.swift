//
//  Model.swift
//  MVVM
//
//  Created by Paramitha on 01/05/24.
//

import Foundation

struct Pokemons: Decodable {
    let count: Int
    let nextOffset: Int
    let results: [Pokemon]
}

struct Pokemon: Decodable {
    let name: String
    let image: String
}
