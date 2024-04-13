//
//  MainDateComponent.swift
//  MonsterDiary
//
//  Created by Damin on 4/12/24.
//

import SwiftUI

struct MainDateComponent: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "252525", alpha: 0.9))
                .opacity(0.9)
                .clipShape(.rect(cornerRadius: 20))
                .frame(width: 227, height: 48)
            
            HStack {
                Text(Date().toString(dateFormat: "yyyy.MM.dd"))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Spacer()
                
                Text(Date().dayString(date: Date()))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.trailing, 20)
            }
            .padding(.horizontal, 20)
            .frame(width: 227, height: 48)
           
        }

    }
}

#Preview {
    MainDateComponent()
}
