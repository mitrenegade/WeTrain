//
//  Constants.swift
//  WeTrain
//
//  Created by Bobby Ren on 10/1/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import Foundation

let TESTING: Int32 = 1 // notifications sent while training
let PRODUCTION: Bool = false // Parse database, stripe key

let TRAINING_TITLES = ["Healthy Heart", "Liposuction", "Mobi-Fit", "The BLT", "Belly Busters", "Tyrannosaurus Flex", "Sports Endurance", "The Shred Factory"]
let TRAINING_SUBTITLES = ["Cardio", "Weight Loss", "Mobility", "Butt, Legs, Thighs", "Core", "Strength and Hypertrophy", "Muscular Endurance", "Toning"]
let TRAINING_ICONS = ["exercise_healthyHeart", "exercise_lipo", "exercise_mobiFit", "exercise_blt", "exercise_bellyBusters", "exercise_tflex", "exercise_sportsEndurance", "exercise_shredFactory"]

enum RequestState: String {
    case NoRequest = "none"
    case Searching = "requested"
    case Matched = "matched"
    case Training = "training"
    case Cancelled = "cancelled"
    case Complete = "complete"
}

let GOOGLE_API_APP_KEY = "AIzaSyA7aDRZVW3-ruvbeB25tzJF5WKr0FjyRac"
let STRIPE_PUBLISHABLE_KEY_DEV = "pk_test_44V2WNWqf37KXEnaJE2CM5rf"
let STRIPE_PUBLISHABLE_KEY_PROD = "pk_live_egDYTQMRk9mIkZYQPp0YtwFn"

let PARSE_APP_ID_DEV = "PSgTQ91JT6JQUjmm5XmdylwCMPzckertjqul6AKL"
let PARSE_CLIENT_KEY_DEV = "EwYejFi8NGJ8XSLLlEfv4XPgSzPksGzeIO94Ljo1"
let PARSE_APP_ID_PROD = "hezlwzG8F2RaalhHOVsUrpn5xN2KNtDa8VTgd8ea"
let PARSE_CLIENT_KEY_PROD = "J0ZkdjRLVBIgaPKAAkVEvGzBQymjv2nUeaPBZkM7"

