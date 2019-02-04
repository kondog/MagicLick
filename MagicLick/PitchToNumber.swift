//
//  PitchToNumber.swift
//  MagicLick
//
//  Created by Yuichiro Kondo on 2019/02/05.
//  Copyright © 2019 Yuichiro Kondo. All rights reserved.
//

import Foundation
class PitchToNumber{
    private var keyOfHarp = ""
    public func SetKey(key: String){
        keyOfHarp = key
    }
    public func GetNumberOfHole(pitch: String) -> String{
        switch keyOfHarp{
        case "C":return GetNumberOfC(pitch: pitch)
        default:return "XX"
        }
    }
    private func GetNumberOfC(pitch: String) -> String{
        switch pitch{
        case "C4":return "+1"
        case "D4":return "-1"
        case "E4":return "+2"
        case "F4":return "-2"
        case "G4":return "+3"
        case "A4":return "-3b"
        case "B4":return "-3"
        case "C5":return "+4"
        case "D5":return "-4"
        case "E5":return "+5"
        case "F5":return "-5"
        case "G5":return "+6"
        case "A5":return "-6"
        case "B5":return "-7"
        case "C6":return "+7"
        case "D6":return "-8"
        case "E6":return "+8"
        case "F6":return "-9"
        case "G6":return "+9"
        case "A6":return "+9"
        case "B6":return "-10"
        case "C7":return "+10"
        default:return "XX"
        }
    }
}
