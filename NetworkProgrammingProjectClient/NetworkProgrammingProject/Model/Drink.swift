//
//  Drink.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/30/24.
//

import Foundation

struct Drink: Hashable, Identifiable {
    var id: UUID = UUID()
    
    var name: String
    var price: Int
    var stock: Int
    let fixedName: String
    var isDailyPresent: Bool = false
    var isMonthPresent: Bool = false
}
