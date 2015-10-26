//
//  Constants.swift
//  WeTrain
//
//  Created by Bobby Ren on 10/1/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import Foundation

let TESTING: Bool = false

let TRAINING_TITLES = ["Healthy Heart", "Liposuction", "Mobi-Fit", "The BLT", "Belly Busters", "Tyrannosaurus Flex", "Sports Endurance", "The Shred Factory"]
let TRAINING_SUBTITLES = ["Cardio", "Weight Loss", "Mobility", "Butt, Legs, Thighs", "Core", "Strength and Hypertrophy", "Muscular Endurance", "Toning"]
let TRAINING_ICONS = ["exercise_healthyHeart", "exercise_lipo", "exercise_mobiFit", "exercise_blt", "exercise_bellyBusters", "exercise_trex", "exercise_sportsEndurance", "exercise_shredFactory"]

enum RequestState: String {
    case NoRequest = "none"
    case Searching = "requested"
    case Matched = "matched"
    case Training = "training"
    case Cancelled = "cancelled"
    case Complete = "complete"
}

let COLOR_TEAL = UIColor(red: 175.0/255.0, green: 232.0/255.0, blue: 218.0/255.0, alpha: 1)