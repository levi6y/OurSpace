//
//  Date.swift
//  OurSpace
//
//  Created by levi6y on 2021/3/19.
//

import Foundation

import Firebase


struct mydate: Identifiable{
    var id: String              //uid of this log
    var description: String
    var year: Int
    var month: Int
    var day: Int
    var spaceuid: String
    var value: Int
    var text: String
}
