//
//  ABDTxPowerViewControllerTableViewController.swift
//  retest
//
//  Created by Raphael Sacle on 3/30/18.
//  Copyright © 2018 Raphael Sacle. All rights reserved.
//

import UIKit

class ABDTxPowerViewController: UITableViewController {
    var bluetoothReader: ABTBluetoothReader?
    /** Tx power label. */
    var txPowerLabel: UILabel?
    
    
    private var txPowerStrings = [Any]()
    private var txPowerIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        txPowerStrings = ["-23 dBm", "-6 dBm", "0 dBm", "4 dBm"]
        txPowerIndex = (txPowerStrings as NSArray).index(of: txPowerLabel?.text)
        if txPowerIndex == NSNotFound {
            txPowerIndex = 0
        }
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return txPowerStrings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = txPowerStrings[indexPath.row] as? String
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId!)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        }
        cell?.textLabel?.text = cellId
        if txPowerIndex == indexPath.row {
            cell?.accessoryType = .checkmark
        }
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if txPowerIndex != indexPath.row {
            let oldIndexPath = IndexPath(row: txPowerIndex, section: 0)
            let newCell: UITableViewCell? = tableView.cellForRow(at: indexPath)
            if newCell?.accessoryType == .none {
                newCell?.accessoryType = .checkmark
                txPowerIndex = indexPath.row
                txPowerLabel?.text = txPowerStrings[txPowerIndex] as! String
            }
            let oldCell: UITableViewCell? = tableView.cellForRow(at: oldIndexPath)
            if oldCell?.accessoryType == .checkmark {
                oldCell?.accessoryType = .none
            }
        }
        if  (bluetoothReader?.isKind(of: ABTAcr1255uj1Reader.self))!{
            let command = [0xe0, 0x00, 0x00, 0x49, UInt8(txPowerIndex)]
        //to review
            var arrayLength = command.count * MemoryLayout<Int8>.size

            bluetoothReader?.transmitEscapeCommand(command, length:  UInt(arrayLength))
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
