//
//  MyUser.swift
//  Week_10_MAD
//
//  Created by Felicia Sword on 30/04/26.
//

import Foundation

struct MyUser: Codable {
    var uid: String = ""
    var email: String = ""
    var name: String = ""
    var password: String = ""
    var achievements: [String] = [] 
}
