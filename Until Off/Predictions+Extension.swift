//
//  Predictions+Extension.swift
//  Until Off
//
//  Created by dasdom on 07.10.15.
//  Copyright © 2015 dasdom. All rights reserved.
//

import Foundation

extension Prediction {
    class func timeStringFromSeconds(_ seconds: Int) -> String? {
//        NSLog(@"seconds: %ld", (long)seconds);
//        if (seconds < 1)
//        {
//            return nil;
//        }
//        NSInteger hours = seconds/3600;
//        NSNumber *minutes = @(seconds/60-hours*60);
//        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//        [formatter setPositiveFormat: @"00"];
//        return [NSString stringWithFormat:@"%ld:%@", (long)hours, [formatter stringFromNumber:minutes]];
        
        guard seconds > 0 else {
            return nil
        }
        
        let hours = seconds/3600
        let minutes = seconds/60-hours*60
        
        let format = "02"
        return "\(hours):\(minutes.format(format))"
    }
}

extension Int {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)d" as NSString, self) as String
    }
}

