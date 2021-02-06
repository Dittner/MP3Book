//
//  DateTimeUtils.swift
//  MP3Book
//
//  Created by Dittner on 02/06/2019.
//

import Foundation
class DateTimeUtils {
    public class func secToHHMMSS(_ sec:Int) -> String {
        if sec < 3600 {
            return String(format: "%02d:%02d", Int(sec / 60), Int(sec % 60))
        } else {
            return String(format: "%d:%02d:%02d", Int(sec / 3600), Int(sec % 3600) / 60, Int(sec % 60))
        }
    }
}
