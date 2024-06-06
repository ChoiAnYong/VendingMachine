//
//   Sales.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 6/6/24.
//

import Foundation

struct Sales {
    var monthSales: [(String, Int)]
    var dailySales: [(String, Int)]
    var drinkMonthSales: [(String, String, Int)]
    var drinkDailySales: [(String, String, Int)]
    
    init(monthSales: [(String, Int)] = [],
         dailySales: [(String, Int)] = [],
         drinkMonthSales: [(String, String, Int)] = [],
         drinkDailySales: [(String, String, Int)] = []
    ) {
        self.monthSales = monthSales
        self.dailySales = dailySales
        self.drinkMonthSales = drinkMonthSales
        self.drinkDailySales = drinkDailySales
    }
}
