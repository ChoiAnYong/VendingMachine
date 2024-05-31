//
//  Drink.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/30/24.
//

import Foundation

struct Drink: Hashable {
    let name: DrinkEnum
    var price: Int
    var stock: Int
}

enum DrinkEnum: String {
    case water = "water"
    case cola = "cola"
    case coffee = "coffee"
    case highCoffee = "high_coffee"
    case pocari = "pocari"
    case oronamin = "oronamin"
}
