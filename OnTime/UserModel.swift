//
//  UserModel.swift
//  OnTime
//
//  Created by Leonnardo Benjamin Hutama on 19/09/19.
//  Copyright © 2019 Leonnardo Benjamin Hutama. All rights reserved.
//

import Foundation

class UserModel: NSObject{
    var name: String
    var wakeUpHour: Int
    var wakeUpMin: Int
    var leaveHour: Int
    var leaveMin: Int
    var clockOutHour: Int
    var clockOutMin: Int
    
    init(name: String, wakeUpHour: Int, wakeUpMin: Int, leaveHour: Int, leaveMin: Int, clockOutHour: Int, clockOutMin: Int){
        self.name = name
        self.wakeUpHour = wakeUpHour
        self.wakeUpMin = wakeUpMin
        self.leaveHour = leaveHour
        self.leaveMin = leaveMin
        self.clockOutHour = clockOutHour
        self.clockOutMin = clockOutMin
    }
    
}


