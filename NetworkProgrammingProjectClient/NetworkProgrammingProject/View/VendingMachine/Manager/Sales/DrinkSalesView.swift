//
//  DrinkSalesView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 6/6/24.
//

import SwiftUI

//음료의 매출을 보여줄 View
struct DrinkSalesView: View {
    private let title: String // 일 매출 or 월 매출
    private let drink: String // 음료
    private let list: [(String, String, Int)] // date, drink, sales
    private let screenWidth = UIScreen.main.bounds.width
   
    
    init(title: String, drink: String, list: [(String, String, Int)]) {
        self.title = title
        self.drink = drink
        self.list = list.filter { $0.1 == drink} // 현재 음료에 해당하는 데이터만 분리해서 초기화
    }
    
    @ViewBuilder
    var body: some View {
        if !list.isEmpty {
            VStack {
                Spacer()
                    .frame(height: 20)
                
                Text("\(drink)")
                    .font(.system(size: 30, weight: .bold))
                
                Text("\(title)")
                    .font(.system(size: 30, weight: .bold))
                
                
                Rectangle()
                    .frame(height: 1)
                
                HStack {
                    HStack {
                        Spacer()
                        Text("날짜")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("매출")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                }
                
                Rectangle()
                    .frame(height: 1)
                
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(0..<list.count, id: \.self) { index in
                            HStack {
                                HStack {
                                    Spacer()
                                    Text("\(list[index].0)")
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    Text(" \(list[index].2)원")
                                    Spacer()
                                }
                            }
                            
                            Rectangle()
                                .frame(height: 1)
                        }
                    }
                }
            }
        } else {
            Text("해당 매출이 없습니다.")
        }
    }
}

#Preview {
    DrinkSalesView(title: "일매출", drink: "물", list: [("2024-06-25", "물", 2500)])
}
