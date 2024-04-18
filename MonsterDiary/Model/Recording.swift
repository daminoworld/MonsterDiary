//
//  Recording.swift
//  MonsterDiary
//
//  Created by Damin on 4/12/24.
//

import Foundation

struct Recording : Equatable {
    let fileURL : URL
    let createdAtDate: Date
    let createdAtString : String
    var isPlaying : Bool
    let day: Week
}
