//
//  DiaryMonsterApp.swift
//  MonsterDiary
//
//  Created by Damin on 4/12/24.
//

import SwiftUI

@main
struct DiaryMonsterApp: App {
    @StateObject var audioManager = AudioRecorderManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(audioManager)
        }
    }
}

