//
//  PredictionsTableViewController.swift
//  Until Off
//
//  Created by dasdom on 07.10.15.
//  Copyright © 2015 dasdom. All rights reserved.
//

import UIKit

class PredictionsTableViewController: UITableViewController {

    var predictionsArray = [Prediction]()
    var managedObjectContext: NSManagedObjectContext?
    
    var dateFormatter: DateFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(PredictionTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = .short
        dateFormatter?.timeStyle = .short
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictionsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PredictionTableViewCell

        let prediction = predictionsArray[indexPath.row]
        if let totalString = Prediction.timeStringFromSeconds(prediction.totalRuntime.intValue) {
            cell.timeLabel.text = "\(totalString) h"
            if let dateFormatter = dateFormatter {
                cell.dateLabel.text = "\(dateFormatter.string(from: prediction.date))"
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let managedObjectContext = managedObjectContext {
            
            tableView.beginUpdates()
            
            let prediction = predictionsArray[indexPath.row]
            managedObjectContext.delete(prediction)
            
            predictionsArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            tableView.endUpdates()
        }
    }
    
}
