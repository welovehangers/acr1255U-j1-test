//
//  ABDReaderViewController.swift
//  retest
//
//  Created by Raphael Sacle on 3/29/18.
//  Copyright © 2018 Raphael Sacle. All rights reserved.
//

import UIKit
import CoreBluetooth
class ABDReaderViewController: UITableViewController { //, CBCentralManagerDelegate
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//
//    }
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        // If the peripheral is not found, then add it to the array.
//        if !peripherals.contains(peripheral) {
//            // Add the peripheral to the array.
//            peripherals.append(peripheral)
//            // Show the peripheral.
//
//            tableView.reloadData()
//            }
//        }
//    }
//
//    var centralManager: CBCentralManager!
    /** Array of peripherals. */
    
    var peripherals = [AnyHashable]()
    /** Selected peripheral. */
    var peripheral: CBPeripheral?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Scan the peripherals.
       // centralManager!.scanForPeripherals(withServices: nil, options: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return peripherals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let peripheral = peripherals[indexPath.row] as? CBPeripheral
        cell?.textLabel?.text = peripheral?.name
        if let aCell = cell {
            return aCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let peripheral = peripheral  {
            let index: Int = peripherals.index(of: peripheral)!
            if index == indexPath.row {
                return
            }
            if index != NSNotFound {
                let oldIndexPath = IndexPath(row: index, section: 0)
                let oldCell: UITableViewCell? = tableView.cellForRow(at: oldIndexPath)
                if oldCell?.accessoryType == .checkmark {
                    oldCell?.accessoryType = .none
                }
            }
        }
            
        
        if let newCell = tableView.cellForRow(at: indexPath) {
            if newCell.accessoryType == .none {
                newCell.accessoryType = .checkmark
                peripheral = peripherals[indexPath.row] as? CBPeripheral
            }
        }
        

        
    }


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
