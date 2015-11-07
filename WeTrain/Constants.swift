//
//  Constants.swift
//  WeTrain
//
//  Created by Bobby Ren on 10/1/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import Foundation

let TESTING: Int32 = DEBUG // notifications sent while training
let PRODUCTION: Bool = false // Parse database

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

let GOOGLE_API_APP_KEY = "AIzaSyA7aDRZVW3-ruvbeB25tzJF5WKr0FjyRac"
let STRIPE_PUBLISHABLE_KEY = "pk_test_xG5SMQiERYrdgLdukSEnH46E"

// TODO: switch to this when published
//let STRIPE_PUBLISHABLE_KEY = "pk_live_MzmtjIQ0XLqVuhWXzPzmVCX9"

let PARSE_APP_ID_DEV = "PSgTQ91JT6JQUjmm5XmdylwCMPzckertjqul6AKL"
let PARSE_CLIENT_KEY_DEV = "EwYejFi8NGJ8XSLLlEfv4XPgSzPksGzeIO94Ljo1"
let PARSE_APP_ID_PROD = "hezlwzG8F2RaalhHOVsUrpn5xN2KNtDa8VTgd8ea"
let PARSE_CLIENT_KEY_PROD = "J0ZkdjRLVBIgaPKAAkVEvGzBQymjv2nUeaPBZkM7"

