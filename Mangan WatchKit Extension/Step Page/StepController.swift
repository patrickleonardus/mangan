//
//  StepController.swift
//  Mangan WatchKit Extension
//
//  Created by Patrick Leonardus on 26/01/21.
//

import UIKit
import WatchKit
import CoreMotion

class StepController: WKInterfaceController {
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    var steps: [String]?
    var rowAt = 0
    let motionManager = CMMotionManager()
    var isRotate = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.steps = context as? [String]
        
        if let count = self.steps?.count {
            tableView.setNumberOfRows(count, withRowType: "steps_cell")
            for index in 0...count-1 {
                if let cell = tableView.rowController(at: index) as? StepCell {
                    let step = steps?[index]
                    let stepDesc = String(step?.dropFirst(2) ?? "")
                    cell.stepCount.setText("Langkah \(index+1)")
                    cell.stepDesc.setText(stepDesc)
                }
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        if (motionManager.isDeviceMotionAvailable == true) {
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (data, error) in
                guard let data = data else { return }
                let rotationX = data.rotationRate.x
                self.rotation(rotate: rotationX)
            }
        } else {
            print("Gyro not available")
        }
        
    }
    
    func rotation(rotate: Double) {
        if rotate > 8 {
            if !isRotate{
                self.isRotate = true
                self.setNext()
                willSetRotate(rotate: false)
            }
        }
        else if rotate < -8 {
            if !isRotate{
                self.isRotate = true
                self.setPrev()
                willSetRotate(rotate: false)
            }
        }
    }
    
    func setPrev(){
        if rowAt != 0 {
            rowAt-=1
            tableView.scrollToRow(at: rowAt)
        }
    }
    
    func setNext(){
        if rowAt != self.steps?.count {
            rowAt+=1
            tableView.scrollToRow(at: rowAt)
        }
    }
    
    func willSetRotate(rotate: Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if rotate {
                self.isRotate = true
            }else {
                self.isRotate = false
            }
        }
    }
    
}
