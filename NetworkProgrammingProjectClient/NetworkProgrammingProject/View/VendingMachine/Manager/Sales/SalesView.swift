//
//  SalesView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 6/6/24.
//

import SwiftUI

//자판기의 매출을 보여줄 View
struct SalesView: View {
    private let title: String // 일 매출 or 월 매출
    private let list: [(String, Int)] // (날짜, 매출)를 담고 있는 배열
    private let screenWidth = UIScreen.main.bounds.width // 현재 디바이스 사이즈
    
    //생성자
    init(title: String, list: [(String, Int)]) {
        self.title = title
        self.list = list
    }
    
    //매출 정보 유무에 따라 화면을 분기
    @ViewBuilder
    var body: some View {
        if !list.isEmpty {
            VStack {
                Spacer()
                    .frame(height: 20)
                
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
                                    Text(" \(list[index].1)원")
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
    SalesView(title: "일매출", list: [("2024-06-06", 1500)])
}
