//
//  PredictionOverView.swift
//  Until Off
//
//  Created by dasdom on 10.10.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

import UIKit

class PredictionOverView: UIView {

    let predictionsArray: [Prediction]
    
    var minimum: Float?
    var maximum: Float?
    var average: Float = 0.0
    
    init(predictionsArray: [Prediction]) {
        self.predictionsArray = predictionsArray
        
        super.init(frame: CGRectZero)
        
        backgroundColor = UIColor.yellowColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        UIColor(white: 0.98, alpha: 1.0).setFill()
        CGContextFillRect(context, rect)
        
        setMiniMaxAndAverageFromPredictionsArray(predictionsArray)
        
        var minimumHour: Float = -1.5
        if let minimum = minimum {
            minimumHour = floor(minimum/3600.0-1.5)
        }
       
        var maximumHour: Float = 0.5
        if let maximum = maximum {
            maximumHour = ceil(maximum/3600.0+0.5)
        }
        
        let (distributionValues, maximumNumberOfValues) = distributionValuesFromPredictionsArray(predictionsArray, minimumHour: minimumHour, maximumHour: maximumHour)
        
        let rectHeight = CGFloat(rect.size.height)
        let numberOfChannels = distributionValues.count
        let normX = floor(frame.size.width-40.0)/CGFloat(numberOfChannels)
        let normY = (rectHeight-150.0)/CGFloat(maximumNumberOfValues)
        
        let attributesDictionary: [NSObject:AnyObject] = [NSFontAttributeName : UIFont.systemFontOfSize(10)]
        
        let stepSize = maximumNumberOfValues < 15 ? 1 : 5
        
        let yOffset = CGFloat(50.0)
        for var i=0; i<maximumNumberOfValues; i+=stepSize {
            let lineRect = CGRectMake(10.0, rectHeight-yOffset-CGFloat(i)*normY, rect.size.width-20.0, 0.5)
            CGContextFillRect(context, lineRect)
            
            let numberString = "\(i)"
            let attributedString = NSAttributedString(string: numberString, attributes: attributesDictionary)
            attributedString.drawAtPoint(CGPointMake(10.0, CGRectGetMaxY(lineRect)-15.0))
        }
    
        for var i=0; i<distributionValues.count; i++ {
            let number = CGFloat(distributionValues[i])
            CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 1.0)
            var channelRect = CGRect(x: 20.0+CGFloat(i)*CGFloat(normX), y: rectHeight-yOffset-max(number*normY,2.0), width: normX-1.0, height: max(number*normY,2.0))
            channelRect = CGRectIntegral(channelRect)
            CGContextFillRect(context, channelRect);

            var drawLine = false
            if numberOfChannels > 20 {
                if (i-1)%10 == 0 {
                    drawLine = true
                }
            } else if numberOfChannels > 5 {
                if (i-1)%5 == 0 {
                    drawLine = true
                }
            } else {
                drawLine = true
            }
            
            if drawLine {
                let string = "\(Int(minimumHour)+i+1)"
                let attributedString = NSAttributedString(string: string, attributes: attributesDictionary)
                attributedString.drawAtPoint(CGPointMake(20.0+(CGFloat(i)+0.5)*normX-attributedString.size().width/2.0, rectHeight-yOffset+5.0))
            }
        }
        
        if minimum == nil || maximum == nil {
            return
        }
        let minimumString = NSString(format: "%.2f", minimum!/3600.0)
        let maximumString = NSString(format: "%.2f", maximum!/3600.0)
        let averageString = NSString(format: "%.2f", average/3600.0)
        let conclusionString = "Minimum \(minimumString) h, Maximum \(maximumString) h, Average \(averageString) h"
        let attributedString = NSAttributedString(string: conclusionString, attributes: attributesDictionary)
        attributedString.drawAtPoint(CGPointMake(20.0, rectHeight-20.0))
    }
    
    func setMiniMaxAndAverageFromPredictionsArray(predictionsArray: [Prediction]) {
        var totalRuntime: Float = 0.0
        for prediction in predictionsArray {
            let runTime = prediction.totalRuntime.floatValue
            if minimum == nil || runTime < minimum {
                minimum = runTime
            }
            if maximum == nil || runTime > maximum {
                maximum = runTime
            }
            totalRuntime += runTime
        }
        if predictionsArray.count > 0 {
            average = totalRuntime/Float(predictionsArray.count)
            
            NSUserDefaults.standardUserDefaults().setInteger(Int(average), forKey: kAverageTotalRuntimeKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func distributionValuesFromPredictionsArray(predictionsArray: [Prediction], minimumHour: Float, maximumHour: Float) -> (distributionValues: [Int], maximumNumberOfValuesInChannels: Int) {
        
        var distributionValues = [Int](count: Int(maximumHour-minimumHour), repeatedValue: 0)
        var maximumNumberOfValues = 1
        for prediction in predictionsArray {
            let index = Int(prediction.totalRuntime.floatValue/3600.0-minimumHour-0.5)
            let numberOfPredictions = distributionValues[index]+1
            distributionValues[index] = numberOfPredictions
            
            if numberOfPredictions > maximumNumberOfValues {
                maximumNumberOfValues = numberOfPredictions
            }
        }
        
        println("distributionValues: \(distributionValues)")
        
        return (distributionValues, maximumNumberOfValues)
    }
}
