//
//  SettingsTableViewController.swift
//  Until Off
//
//  Created by dasdom on 18.10.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

import UIKit

//let savingFrequencyIdentifer = "savingFrequencyIdentifer"

enum SavingFrequency: Int {
    case magic = 0
    case oncePerDay
    case manually
    
    func name() -> String {
        switch self {
        case .magic:
            return "Magic"
        case .oncePerDay:
            return "Once per day"
        case .manually:
            return "Manually"
        }
    }
}

class SettingsTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var savingsFrequency = SavingFrequency.magic
    var pickerIndexPath: IndexPath?// = NSIndexPath(forRow: 1, inSection: 0)
    
    let pickerCellIdentifer = "pickerCellIdentifer"
//    let savingFrequencyIdentifer = "savingFrequencyIdentifer"
    var showTimeOfOff = false
    
    class func savingFrequencyIdentifer() -> String {
        return "savingFrequencyIdentifer"
    }
    
    class func showTimeOfOffKey() -> String {
        return "showTimeOfOffKey"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(SettingsTableViewController.dismiss(_:)))
        
        savingsFrequency = SavingFrequency(rawValue: UserDefaults.standard.integer(forKey: SettingsTableViewController.savingFrequencyIdentifer()))!
        
        showTimeOfOff = UserDefaults.standard.bool(forKey: SettingsTableViewController.showTimeOfOffKey())
        
        tableView.register(PickerTableViewCell.self, forCellReuseIdentifier: pickerCellIdentifer)
        
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 1
        if pickerIndexPath != nil && section == 0 {
            numberOfRows += 1
        }
        return numberOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let pickerIndexPath = pickerIndexPath {
            if (pickerIndexPath as NSIndexPath).compare(indexPath) == ComparisonResult.orderedSame {
                let cell = tableView.dequeueReusableCell(withIdentifier: pickerCellIdentifer, for: indexPath) as! PickerTableViewCell
                cell.pickerView.delegate = self
                cell.pickerView.selectRow(savingsFrequency.rawValue, inComponent: 0, animated: true)
                return cell
            }
        }
        
        let settingsCellIdentifer = "settingsCellIdentifer"
        var cell = tableView.dequeueReusableCell(withIdentifier: settingsCellIdentifer)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: settingsCellIdentifer)
        }
        
        let shortPath = (indexPath.section, indexPath.row)
        switch shortPath {
        case (0, 0):
            cell?.textLabel?.text = NSLocalizedString("Save prediction", comment: "")
            cell?.detailTextLabel?.text = NSLocalizedString(savingsFrequency.name(), comment: "")
        case (1, 0):
            cell?.textLabel?.text = NSLocalizedString("Show off time", comment: "")
            cell?.detailTextLabel?.text = NSLocalizedString("\(showTimeOfOff)", comment: "")
        default:
            break
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let pickerIndexPath = pickerIndexPath {
            if (pickerIndexPath as NSIndexPath).compare(indexPath) == ComparisonResult.orderedSame {
                return 162.0
            }
        }
        return 44.0
    }
    
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            tableView.beginUpdates()
            if let pickerIndexPath = pickerIndexPath {
                tableView.deleteRows(at: [pickerIndexPath], with: UITableViewRowAnimation.automatic)
                self.pickerIndexPath = nil
            } else {
                pickerIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
                tableView.insertRows(at: [pickerIndexPath!], with: UITableViewRowAnimation.automatic)
            }
            tableView.endUpdates()
        } else {
            showTimeOfOff = !showTimeOfOff
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    
    // MARK: - Picker data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var name = "Error Error Error"
        if let savingsFequency = SavingFrequency(rawValue: row) {
            name = savingsFequency.name()
        }
        return NSAttributedString(string: name)
    }
    
    // MARK: - Picker delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let shortPath = (pickerIndexPath!.section, pickerIndexPath!.row)
        switch shortPath {
        case (0, 1):
            savingsFrequency = SavingFrequency(rawValue: row)!
            let indexPath = IndexPath(row: shortPath.1-1, section: shortPath.0)
            tableView.reloadRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
    
    func dismiss(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(savingsFrequency.rawValue, forKey: SettingsTableViewController.savingFrequencyIdentifer())
        UserDefaults.standard.set(showTimeOfOff, forKey: SettingsTableViewController.showTimeOfOffKey())
        UserDefaults.standard.synchronize()
        
        self.dismiss(animated: true, completion: nil)
    }

}
