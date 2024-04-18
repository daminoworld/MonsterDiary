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
    @StateObject var arManager = ARModelManager()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(audioManager)
                .environmentObject(arManager)
        }
    }
}

