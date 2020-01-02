//
//  PredictionOverView.swift
//  Until Off
//
//  Created by dasdom on 10.10.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PredictionOverView: UIView {

    var predictionsArray: [Prediction]
    
    var minimum: Float?
    var maximum: Float?
    var average: Float = 0.0
    
    init(predictionsArray: [Prediction]) {
        self.predictionsArray = predictionsArray
        
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.yellow
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        UIColor(white: 0.98, alpha: 1.0).setFill()
        context?.fill(rect)
        
        setMiniMaxAndAverageFromPredictionsArray(predictionsArray)
        
        var minimumHour: Float = -1.5
        if let minimum = minimum {
            minimumHour = floor(minimum/3600.0-1.5)
        }
       
        var maximumHour: Float = 0.5
        if let maximum = maximum {
            maximumHour = ceil(maximum/3600.0+0.5)
        }
        
        let (distributionValues, colorValues, maximumNumberOfValues) = distributionValuesFromPredictionsArray(predictionsArray, minimumHour: minimumHour, maximumHour: maximumHour)
        
        let rectHeight = CGFloat(rect.size.height)
        let numberOfChannels = distributionValues.count
        let normX = floor(frame.size.width-40.0)/CGFloat(numberOfChannels)
        let normY = (rectHeight-150.0)/CGFloat(maximumNumberOfValues)
        
        let attributesDictionary = [NSFontAttributeName : UIFont.systemFont(ofSize: 10)]
        
        let stepSize = maximumNumberOfValues < 15 ? 1 : 5
        
        let yOffset = CGFloat(70.0)
        for i in stride(from: 0, to: maximumNumberOfValues, by: stepSize) {
            let lineRect = CGRect(x: 20.0, y: rectHeight-yOffset-CGFloat(i)*normY, width: rect.size.width-20.0, height: 0.5)
            context?.fill(lineRect)
            
            let numberString = "\(i)"
            let attributedString = NSAttributedString(string: numberString, attributes: attributesDictionary)
            attributedString.draw(at: CGPoint(x: 20.0, y: lineRect.maxY-15.0))
        }
        let attributesYString = NSAttributedString(string: "#", attributes: attributesDictionary)
        attributesYString.draw(at: CGPoint(x: 10.0, y: rectHeight-yOffset-CGFloat(maximumNumberOfValues)*normY+10.0))
    
        for i in 0 ..< distributionValues.count {
            let number = CGFloat(distributionValues[i])
            let colorValue = CGFloat(colorValues[i])
            context?.setFillColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0)
            let channelRect = CGRect(x: 20.0+CGFloat(i)*normX, y: rectHeight-yOffset-max(number*normY,2.0), width: normX-1.0, height: max(number*normY,2.0))
//            channelRect = CGRectIntegral(channelRect)
            context?.fill(channelRect);

            var drawLable = false
            if numberOfChannels > 20 {
                if (i-1)%10 == 0 {
                    drawLable = true
                }
            } else if numberOfChannels > 5 {
                if (i-1)%5 == 0 {
                    drawLable = true
                }
            } else {
                drawLable = true
            }
            
            if drawLable {
                let string = "\(Int(minimumHour)+i+1)"
                let attributedString = NSAttributedString(string: string, attributes: attributesDictionary)
                attributedString.draw(at: CGPoint(x: 20.0+(CGFloat(i)+0.5)*normX-attributedString.size().width/2.0, y: rectHeight-yOffset+5.0))
            }
        }
        
        let xLabelString = "total battery duration"
        let attributedXLabelString = NSAttributedString(string: xLabelString, attributes: attributesDictionary)
        attributedXLabelString.draw(at: CGPoint(x: rect.size.width-attributedXLabelString.size().width-20, y: rectHeight-yOffset+20.0))

        guard let minimum = minimum else { return }
        guard let maximum = maximum else { return }
        
        let minimumString = NSString(format: "%.2f", minimum/3600.0)
        let maximumString = NSString(format: "%.2f", maximum/3600.0)
        let averageString = NSString(format: "%.2f", average/3600.0)
        let conclusionString = "Minimum \(minimumString) h, Maximum \(maximumString) h, Average \(averageString) h"
        let attributedString = NSAttributedString(string: conclusionString, attributes: attributesDictionary)
        attributedString.draw(at: CGPoint(x: 20.0, y: rectHeight-20.0))
    }
    
    func setMiniMaxAndAverageFromPredictionsArray(_ predictionsArray: [Prediction]) {
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
            
            UserDefaults.standard.set(Int(average), forKey: kAverageTotalRuntimeKey)
            UserDefaults.standard.synchronize()
        }
    }

    func distributionValuesFromPredictionsArray(_ predictionsArray: [Prediction], minimumHour: Float, maximumHour: Float) -> (distributionValues: [Int], colorValues: [Float], maximumNumberOfValuesInChannels: Int) {
        
        var distributionValues = [Int](repeating: 0, count: Int(maximumHour-minimumHour))
        var colorValues = [Float](repeating: 0.0, count: Int(maximumHour-minimumHour))
        var maximumNumberOfValues = 1
        for prediction in predictionsArray {
            let index = Int(prediction.totalRuntime.floatValue/3600.0-minimumHour-0.5)
            let timeDiffInHours = Date().timeIntervalSince(prediction.date)/3600.0
            let colorFactor = max(0.1, min(1.0, 1200.0/timeDiffInHours))
            print("timeDiff: \(timeDiffInHours), index: \(index), colorFactor: \(colorFactor)")

            let numberOfPredictions = distributionValues[index]+1
            distributionValues[index] = numberOfPredictions
            
            let colorValue = colorValues[index]+Float(colorFactor)
            colorValues[index] = colorValue
            
            if numberOfPredictions > maximumNumberOfValues {
                maximumNumberOfValues = numberOfPredictions
            }
        }
        
        for i in 0 ..< colorValues.count {
            colorValues[i] = min(1.0-colorValues[i]/max(Float(distributionValues[i]), 1.0), 0.8)
        }
    
        print("distributionValues: \(distributionValues)")
        print("colorValues: \(colorValues)")
        
        return (distributionValues, colorValues, maximumNumberOfValues)
    }
    
    func deletePredictions() {
        predictionsArray = [Prediction]()
    }
}
