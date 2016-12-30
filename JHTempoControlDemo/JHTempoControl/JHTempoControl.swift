//
//  JHTempoControl.swift
//  TempoControl
//
//  Created by Joshua Herkness on 10/20/14.
//  Copyright (c) 2014 Joshua Herkness. All rights reserved.
//

import Foundation
import UIKit

protocol JHTempoControlDelegate: class {
    func tempoControl(_ JHTempoControl: JHTempoControl, tagForValue value: Int) -> String?
    func tempoControl(_ JHTempoControl: JHTempoControl, valueMultiplierAfterInterval interval: Double) -> Double?
}

/*
 * Number of data points needed to calculate the 'tapped' tempo.
 * An increase in data points will increase the accuracy, but also
 * increase the memory usage.
 */
let MaxDataPoints = 2

/*
 * Idle durration in which data points will refresh (in seconds).
 */
let RefreshThreshhold = 5

/*
 * Speeds within this threshold from the average will not be considered
 * in calculation.
 */
let SpeedThreshhold = 10

@IBDesignable class JHTempoControl: UIControl {
    
    private var speeds: NSMutableArray = NSMutableArray()
    
    var delegate: JHTempoControlDelegate?
    
    @IBInspectable var value: Int = Int(60) {
        didSet {
            validateValue()
            
            // Update the view
            self.centerButton.setTitle(String(value) , for: UIControlState())
            self.tagLabel.text = delegate?.tempoControl(self, tagForValue: value)
        }
    }
    
    /*
     * Lower bound of value's range.
     */
    @IBInspectable var minimumValue: Int = 0 {
        didSet {
            validateValue()
        }
    }
    
    /*
     * Upper bound of value's range
     */
    @IBInspectable var maximumValue: Int = 100 {
        didSet {
            validateValue()
        }
    }
    
    /*
     * Amount used to increment and decrement value.
     */
    @IBInspectable var stepValue: Int = 1
    
    lazy var decreaseButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0,y: 0,width: self.frame.width/4,height: self.frame.height)
        button.setTitleColor(self.tintColor, for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        button.setBackgroundImage(UIImage(color: UIColor.clear), for: UIControlState())
        button.setBackgroundImage(UIImage(color: self.tintColor), for: UIControlState.highlighted)
        button.setTitle("-", for: UIControlState())
        button.addTarget(self, action: #selector(JHTempoControl.decreaseButtonAction(_:)), for: UIControlEvents.touchDown)
        return button
    }()
    
    lazy var increaseButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 3*(self.frame.width/4),y: 0,width: self.frame.width/4,height: self.frame.height)
        button.setTitleColor(self.tintColor, for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        button.setBackgroundImage(UIImage(color: UIColor.clear), for: UIControlState())
        button.setBackgroundImage(UIImage(color: self.tintColor), for: UIControlState.highlighted)
        button.setTitle("+", for: UIControlState())
        button.addTarget(self, action: #selector(JHTempoControl.increaseButtonAction(_:)), for: UIControlEvents.touchDown)
        return button
    }()
    
    lazy var centerButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: self.frame.size.width/4,y: 0,width: self.frame.size.width/2,height: self.frame.size.height)
        button.setTitleColor(self.tintColor, for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        button.setBackgroundImage(UIImage(color: UIColor.clear), for: UIControlState())
        button.setBackgroundImage(UIImage(color: self.tintColor), for: UIControlState.highlighted)
        button.addTarget(self, action: #selector(JHTempoControl.centerButtonDownAction(_:)), for: UIControlEvents.touchDown)
        button.addTarget(self, action: #selector(JHTempoControl.centerButtonUpAction(_:)), for: [UIControlEvents.touchUpInside, UIControlEvents.touchDragExit, UIControlEvents.touchCancel])
        button.contentVerticalAlignment = UIControlContentVerticalAlignment.top
        button.titleLabel?.textAlignment = NSTextAlignment.center
        return button
    }()
    
    lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0,y: 2*(self.frame.size.height/3),width: self.frame.size.width/2,height: (self.frame.size.height/3))
        label.textColor = self.tintColor
        label.textAlignment = NSTextAlignment.center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: label.font.fontName, size: 10.0)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(decreaseButton);
        self.addSubview(increaseButton);
        self.addSubview(centerButton);
        centerButton.addSubview(tagLabel)
        
        centerButton.setTitle(String(value), for: UIControlState())
        tagLabel.text = delegate?.tempoControl(self, tagForValue: value)
    }
    
    override func tintColorDidChange() {
        
        super.tintColorDidChange()
        
        // Update all colors that use this tint.
        decreaseButton.setTitleColor(self.tintColor, for: UIControlState())
        increaseButton.setTitleColor(self.tintColor, for: UIControlState())
        centerButton.setTitleColor(self.tintColor, for: UIControlState())
        tagLabel.textColor = self.tintColor
    }
    
    func increaseButtonAction(_ sender: UIButton!) {
        cancelLastStepDispatchQueueTask()
        stepValue(sender, increment: true, fromStartDate: Date())
    }
    
    func decreaseButtonAction(_ sender: UIButton!) {
        cancelLastStepDispatchQueueTask()
        stepValue(sender, increment: false, fromStartDate: Date())
    }
    
    func centerButtonUpAction(_ sender: UIButton!) {
        // Change tag label color
        tagLabel.textColor = self.tintColor
    }
    
    // TODO: - Clean up math
    private var previouseDate: Date = Date()
    func centerButtonDownAction(_ sender: UIButton!) {
        
        // Change tag label color
        tagLabel.textColor = UIColor.white
            
        //Make sure the speed data should not refresh
        if(Float(-previouseDate.timeIntervalSinceNow) > Float(RefreshThreshhold)){
            self.speeds.removeAllObjects()
            previouseDate = Date()
        }
        
        while (self.speeds.count >= MaxDataPoints){
            self.speeds.removeObject(at: 0)
        }
        
        self.speeds.add(-previouseDate.timeIntervalSinceNow)
        
        //Trim values that lie outside average
        let averageSpeed: Double = (self.speeds as AnyObject).value(forKeyPath: "@avg.self") as! Double
        
        for i in 0 ..< self.speeds.count {
            
            if(fabs(((self.speeds.object(at: i) as AnyObject).doubleValue) - averageSpeed) > Double(SpeedThreshhold)){
                
                self.speeds.removeObject(at: i)
            }
            
        }
        
        // Calculate the new value
        value = Int(Double(1) * (Double(60) / Double(averageSpeed)))
        
        // Set the previouse date to the current date
        previouseDate = Date();
    }
    
    private var lastTask: DispatchWorkItem?
    private func stepValue(_ button: UIButton, increment: Bool, fromStartDate startDate: Date?) {
        if button.state == UIControlState.highlighted {
            
            var startDate: Date? = startDate
            
            // Calculate the time interval between now and when the step
            var timeInterval: Double?
            var timeUntilNextDispatch: Double?
            if let date = startDate {
                timeInterval = Date().timeIntervalSince(date)
                timeUntilNextDispatch = pow(M_E, (-1 * (Date().timeIntervalSince(date))/4)) * 1000000000
            } else {
                startDate = Date()
            }
            
            var stepValueMultiplier: Double?
            if let interval = timeInterval {
                stepValueMultiplier = delegate?.tempoControl(self, valueMultiplierAfterInterval: interval)
            }
            
            if let multiplier = stepValueMultiplier {
                let newValue: Int = Int(Double(stepValue) * multiplier)
                value = increment ? value + newValue : value - newValue
            } else {
                value = increment ? value + stepValue : value - stepValue
            }

            let task = DispatchWorkItem {
                self.stepValue(button, increment: increment, fromStartDate: startDate)
            }
            
            if let timeUntilNextDispatch = timeUntilNextDispatch {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(timeUntilNextDispatch)) / Double(NSEC_PER_SEC), execute: task)
            }
            
            lastTask = task
        }
    }
    
    private func cancelLastStepDispatchQueueTask() {
        // Cancel the last tast to be placed into the dispatch queue.
        if let task = lastTask {
            task.cancel()
        }
    }
    
    
    /*
     * Ensure that the value is valid, valid being within the
     * range minimumValue...maximumValue.
     */
    private func validateValue() {
        if value < minimumValue {
            value = minimumValue
        } else if value > maximumValue {
            value = maximumValue
        }
    }
}
