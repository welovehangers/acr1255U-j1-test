//
//  ViewController.swift
//  retest
//
//  Created by Raphael Sacle on 3/6/18.
//  Copyright © 2018 Raphael Sacle. All rights reserved.
//

import UIKit
import CoreBluetooth

class ABDViewController: UITableViewController, UIAlertViewDelegate, CBCentralManagerDelegate, ABTBluetoothReaderManagerDelegate, ABTBluetoothReaderDelegate {
    

    
    @IBOutlet weak var readerLabel: UILabel!
    @IBOutlet weak var masterKeyLabel: UILabel!
    @IBOutlet weak var atrLabel: UILabel!
    @IBOutlet weak var cardStatusLabel: UILabel!
    @IBOutlet weak var batteryStatusLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var commandApduLabel: UILabel!
    @IBOutlet weak var responseApduLabel: UILabel!
    @IBOutlet weak var escapeCommandLabel: UILabel!
    @IBOutlet weak var escapeResponseLabel: UILabel!
    @IBOutlet weak var txPowerLabel: UILabel!
    
    var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var peripherals = [AnyHashable]()
    
    private var bluetoothReaderManager: ABTBluetoothReaderManager?
    private var bluetoothReader: ABTBluetoothReader?
    
    //weak var readerViewController: ABDReaderViewController!
    weak var deviceInfoViewController: ABDDeviceInfoViewController!
    private var defaults: UserDefaults?
    private var masterKey: Data?
    private var commandApdu: Data?
    private var escapeCommand: Data?

    //  Converted with Swiftify v1.0.6472 - https://objectivec2swift.com/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //centralManager = BluetoothManager.getInstance()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
        peripherals = [Any]() as! [AnyHashable]
 
        bluetoothReaderManager = ABTBluetoothReaderManager()
        bluetoothReaderManager!.delegate = self
        defaults = UserDefaults.standard
        // Load the master key.
        masterKey = defaults!.data(forKey: "MasterKey")
        if masterKey == nil {
        
            masterKey = ABDHex.byteArray(fromHexString: "FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF")
        }
        masterKeyLabel.text = ABDHex.hexString(fromByteArray: masterKey! )
        // Load the command APDU.
        commandApdu = defaults?.data(forKey: "CommandApdu")
        if commandApdu == nil {
            commandApdu = ABDHex.byteArray(fromHexString: "00 84 00 00 08")
        }
        commandApduLabel.text = ABDHex.hexString(fromByteArray: commandApdu!)
        // Load the escape command.
        escapeCommand = defaults?.data(forKey: "EscapeCommand")
        if escapeCommand == nil {
            escapeCommand = ABDHex.byteArray(fromHexString: "04 00")
        }
        escapeCommandLabel.text = ABDHex.hexString(fromByteArray: escapeCommand!)
        readerLabel.text = ""
        atrLabel.text = ""
        cardStatusLabel.text = ""
        batteryStatusLabel.text = ""
        batteryLevelLabel.text = ""
        responseApduLabel.text = ""
        escapeResponseLabel.text = ""
        masterKeyLabel.numberOfLines = 0
        atrLabel.numberOfLines = 0
        commandApduLabel.numberOfLines = 0
        responseApduLabel.numberOfLines = 0
        escapeCommandLabel.numberOfLines = 0
        escapeResponseLabel.numberOfLines = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearData(_ sender: Any?) {
        atrLabel.text = ""
        cardStatusLabel.text = ""
        batteryStatusLabel.text = ""
        batteryLevelLabel.text = ""
        responseApduLabel.text = ""
        escapeResponseLabel.text = ""
        tableView.reloadData()
    }


//  Converted with Swiftify v1.0.6472 - https://objectivec2swift.com/
// MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "ShowReaders") {
        let controller = segue.destination as! UINavigationController
        let readerViewController = controller.topViewController as! ABDReaderViewController
        readerViewController.peripherals = peripherals
        readerViewController.peripheral = nil
        // Clear the reader name.
        readerLabel.text = ""
        tableView.reloadData()
        // Clear the data.
        clearData(nil)
        // Detach the peripheral.
        bluetoothReader?.detach()
        // Disconnect the peripheral.
        if peripheral != nil {
            centralManager?.cancelPeripheralConnection(peripheral!)
            //centralManager.disconnectPeripheral()
            peripheral = nil
        }
        // Remove all peripherals.
        peripherals.removeAll()
        
        //centralManager.startScanPeripheral()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    else if (segue.identifier == "ShowDeviceInfo") {
        
        // Get the device information.
        
        deviceInfoViewController = segue.destination as! ABDDeviceInfoViewController
        bluetoothReader?.getDeviceInfo(withType: UInt(ABTBluetoothReaderDeviceInfoSystemId))
        bluetoothReader?.getDeviceInfo(withType: UInt(ABTBluetoothReaderDeviceInfoModelNumberString))
        bluetoothReader?.getDeviceInfo(withType: UInt(ABTBluetoothReaderDeviceInfoSerialNumberString))
        bluetoothReader?.getDeviceInfo(withType: UInt(ABTBluetoothReaderDeviceInfoFirmwareRevisionString))
        bluetoothReader?.getDeviceInfo(withType: UInt(ABTBluetoothReaderDeviceInfoHardwareRevisionString))
        bluetoothReader?.getDeviceInfo(withType: UInt(ABTBluetoothReaderDeviceInfoManufacturerNameString))
        
        
    
    }
    else if (segue.identifier == "ShowTxPower") {
        let txPowerViewController = segue.destination as! ABDTxPowerViewController
        txPowerViewController.bluetoothReader = bluetoothReader
        txPowerViewController.txPowerLabel = txPowerLabel
    }
    
}

@IBAction func unwindToMain(segue: UIStoryboardSegue) {
    
   
  
    // If the peripheral is selected, then connect it.
    if let readerViewController = segue.source as? ABDReaderViewController, readerViewController.peripheral != nil {
        
        // Stop the scan.
        //centralManager.stopScanPeripheral()
        centralManager.stopScan()
        
        // Store the peripheral.
        peripheral = readerViewController.peripheral!
        
        // Show the peripheral.
        readerLabel.text = peripheral?.name
        tableView.reloadData()
        // Connect the peripheral.
        //centralManager!.connectPeripheral(peripheral!)
        centralManager.connect(peripheral!, options: nil)
    }
    }
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
        if (cell?.reuseIdentifier == "MasterKey") {
            // Modify the master key.
            let alert = UIAlertView(title: "Master Key", message: "Enter the HEX string:", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "")
            alert.alertViewStyle = .plainTextInput
            alert.tag = 0
            let alertTextField: UITextField? = alert.textField(at: 0)
            let test = ABDHex.hexString(fromByteArray: masterKey! as Data?)
            alertTextField?.text = test
            alert.show()
        }
        else if (cell?.reuseIdentifier == "CommandApdu") {
            // Modify the command APDU.
            let alert = UIAlertView(title: "Command APDU", message: "Enter the HEX string:", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "")
            alert.alertViewStyle = .plainTextInput
            alert.tag = 1
            let alertTextField: UITextField? = alert.textField(at: 0)
            let test = ABDHex.hexString(fromByteArray: commandApdu!)
            alertTextField?.text = test
            alert.show()
        }
        else if (cell?.reuseIdentifier == "EscapeCommand") {
            // Modify the escape command.
            
            let alert = UIAlertView(title: "Escape Command", message: "Enter the HEX string:", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "")
            alert.alertViewStyle = .plainTextInput
            alert.tag = 2
            let alertTextField: UITextField? = alert.textField(at: 0)
            alertTextField?.text = ABDHex.hexString(fromByteArray: escapeCommand!)
            alert.show()
        }
        else if (cell?.reuseIdentifier == "UseDefaultKey") {
            masterKeyLabel.text = "FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF"
            masterKey = ABDHex.byteArray(fromHexString: masterKeyLabel.text!)
            // Save the master key.
            defaults?.set(masterKey, forKey: "MasterKey")
            defaults?.synchronize()
        }
        else if (cell?.reuseIdentifier == "UseDefaultKey2") {
            masterKeyLabel.text = "41 43 52 31 32 35 35 55 2D 4A 31 20 41 75 74 68"
            masterKey = ABDHex.byteArray(fromHexString: masterKeyLabel.text!)
            // Save the master key.
            defaults!.set(masterKey, forKey: "MasterKey")
            defaults!.synchronize()
        }
        else if (cell?.reuseIdentifier == "GetBatteryStatus") {
            if (bluetoothReader is ABTAcr3901us1Reader) {
                let reader = bluetoothReader as? ABTAcr3901us1Reader
                // Clear the battery status.
                batteryStatusLabel.text = ""
                self.tableView.reloadData()
                // Get the battery status.
                reader?.getBatteryStatus()
            }
        }
        else if (cell?.reuseIdentifier == "AuthenticateReader") {
            // Authenticate the reader.
       
//            bluetoothReader!.authenticate(withMasterKey: masterKey!)
            test.authenticate(with:bluetoothReader!)
        }
        else if (cell?.reuseIdentifier == "GetBatteryLevel") {
            if (bluetoothReader is ABTAcr1255uj1Reader) {
                let reader = bluetoothReader as? ABTAcr1255uj1Reader
                // Clear the battery level.
                batteryLevelLabel.text = ""
                self.tableView.reloadData()
                // Get the battery level.
                reader?.getBatteryLevel()
            }
        }
        else if (cell?.reuseIdentifier == "EnablePolling") {
            if (bluetoothReader is ABTAcr1255uj1Reader) {
                let command: [UInt8]  = [0xe0, 0x00, 0x00, 0x40, 0x01]
                let length = command.count * MemoryLayout<Int8>.size
                //bluetoothReader?.transmitEscapeCommand(command, length:UInt(command.count))
                bluetoothReader?.transmitEscapeCommand(command, length:  UInt(length))
            }
        }
        else if (cell?.reuseIdentifier == "DisablePolling") {
            if (bluetoothReader is ABTAcr1255uj1Reader) {
                let command: [UInt8]  = [0xe0, 0x00, 0x00, 0x40, 0x00]
                 let length = command.count * MemoryLayout<Int8>.size
                bluetoothReader?.transmitEscapeCommand(command, length:  UInt(length))
            }
        }
        else if (cell?.reuseIdentifier == "PowerOnCard") {
            // Clear the ATR string.
            atrLabel.text = ""
            bluetoothReader?.powerOffCard()
        }
        else if (cell?.reuseIdentifier == "GetCardStatus") {
            // Clear the card status.
            cardStatusLabel.text = ""
            self.tableView.reloadData()
            // Get the card status.
            bluetoothReader?.getCardStatus()
        }
        else if (cell?.reuseIdentifier == "TransmitApdu") {
            // Clear the response APDU.
            responseApduLabel.text = ""
            self.tableView.reloadData()
            // Transmit the APDU.
            bluetoothReader?.transmitApdu(commandApdu)
        }
        else if (cell?.reuseIdentifier == "TransmitEscapeCommand") {
            // Clear the escape response.
            escapeResponseLabel.text = ""
            self.tableView.reloadData()
            // Transmit the escape command.
            bluetoothReader?.transmitEscapeCommand(escapeCommand)
        }
        else if (cell?.reuseIdentifier == "About") {
            // Show the version information.
            let infoDictionary = Bundle.main.infoDictionary
            let name = infoDictionary?["CFBundleDisplayName"] as? String
            let version = infoDictionary?["CFBundleShortVersionString"] as? String
            let build = infoDictionary?["CFBundleVersion"] as? String
            
            showAlert(title:"About \(name ?? "")", content:"Version \(version ?? "") (\(build ?? ""))")
          
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = tableView.rowHeight
        var label: UILabel? = nil
        switch indexPath.section {
        case 0:
            if indexPath.row == 2 {
                label = masterKeyLabel
            }
        case 1:
            if indexPath.row == 0 {
                label = atrLabel
            }
        case 2:
            if indexPath.row == 0 {
                label = commandApduLabel
            }
            else if indexPath.row == 1 {
                label = responseApduLabel
            }
            
        case 3:
            if indexPath.row == 0 {
                label = escapeCommandLabel
            }
            else if indexPath.row == 1 {
                label = escapeResponseLabel
            }
            
        default:
            break
        }
        if label != nil {
            // Adjust the cell height.
            #if iOSVersionMinRequired7
                let labelSize = label?.text?.size(with: label?.font, constrainedToSize: CGSize(width: tableView.frame.size.width - 40.0, height: MAXFLOAT), lineBreakMode: label?.lineBreakMode)
                // Set the row height to 44 if it is less than zero (iOS 8.0).
                if height < 0 {
                    height = 44
                }
                height += labelSize?.height ?? 0.0
            #else
                let labelRect: CGRect? = label?.text?.boundingRect(with: CGSize(width: tableView.frame.size.width - 40.0, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: label?.font], context: nil)
                // Set the row height to 44 if it is less than zero (iOS 8.0).
                if height < 0 {
                    height = 44
                }
                height += (labelRect?.size.height)!
            #endif
        }
        return height
    }
    // MARK: - Alert View
    private func alertView(_ alertView: UIAlertController, clickedButtonAt buttonIndex: Int) {
        var masterKey: Data? = nil
        var commandApdu: Data? = nil
        var escapeCommand: Data? = nil
       
        switch alertView.view.tag {
        case 0:
            // Master key.
            masterKey = ABDHex.byteArray(fromHexString: (alertView.textFields![0].text)!)
            if !(self.masterKey == masterKey) {
                self.masterKey = masterKey
                masterKeyLabel.text = ABDHex.hexString(fromByteArray: self.masterKey!)
                // Save the master key.
                defaults?.set(masterKey, forKey: "MasterKey")
                defaults?.synchronize()
            }
        case 1:
            // Command APDU.
            commandApdu = ABDHex.byteArray(fromHexString: (alertView.textFields![0].text)!)
            if !(self.commandApdu ==  commandApdu) {
                self.commandApdu = commandApdu
                commandApduLabel.text = ABDHex.hexString(fromByteArray: self.commandApdu!)
                // Save the command APDU.
                defaults?.set(commandApdu, forKey: "CommandApdu")
                defaults?.synchronize()
            }
        case 2:
            // Escape command.
            escapeCommand = ABDHex.byteArray(fromHexString: (alertView.textFields![0].text)!)
            if !(self.escapeCommand == escapeCommand) {
                self.escapeCommand = escapeCommand
                escapeCommandLabel.text = ABDHex.hexString(fromByteArray: self.escapeCommand!)
                // Save the escape command.
                defaults?.set(commandApdu, forKey: "EscapeCommand")
                defaults?.synchronize()

            }
        default:
            break
        }
    }
    
    
    
    
    // MARK: - Central Manager
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
       
        var message: String? = nil
        
        switch central.state {
        case .unknown, .resetting:
            message = "The update is being started. Please wait until Bluetooth is ready."
        case .unsupported:
            message = "This device does not support Bluetooth low energy."
        case .unauthorized:
            message = "This app is not authorized to use Bluetooth low energy."
        case .poweredOn:
            break
        default:
            break
        }
        
        if message != nil {
            self.showAlert(title:"Bluetooth", content:message!)
        }
   
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        if !self.peripherals.contains(peripheral), let peripheralName = peripheral.name, peripheralName.uppercased().hasPrefix("ACR"){
            peripherals.append (peripheral)
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Detect the Bluetooth reader.
        bluetoothReaderManager!.detectReader(with: peripheral)
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        debugPrint("### Failed to connect to this reader: \(peripheral.name ?? "{no name}")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        showAlert(title:"Information", content:"The reader is disconnected successfully.")
    }
        
    
    // MARK: - Bluetooth Reader
    func bluetoothReaderManager(_ bluetoothReaderManager: ABTBluetoothReaderManager, didDetect reader: ABTBluetoothReader, peripheral: CBPeripheral, error: Error?) {

        debugPrint("### attaching ... ")
        
        // Store the Bluetooth reader.
        bluetoothReader = reader
        bluetoothReader?.delegate = self
        // Attach the peripheral to the Bluetooth reader.
        bluetoothReader?.attach(peripheral)

    }
    
    // MARK: - Bluetooth Reader
    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didAttach peripheral: CBPeripheral, error: Error?) {
        
        showAlert(title:"Information", content:"The reader is attached to the peripheral successfully.")

    }


    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didReturnDeviceInfo deviceInfo: NSObject, type: UInt, error: Error?) {
        
        debugPrint("### didReturnDeviceInfo ... ")
        
        if deviceInfoViewController != nil {
            switch Int(type) {
            case ABTBluetoothReaderDeviceInfoSystemId:
                // Show the system ID.
                deviceInfoViewController?.systemIdLabel.text = ABDHex.hexString(fromByteArray: (deviceInfo as? Data)!)
            case ABTBluetoothReaderDeviceInfoModelNumberString:
                // Show the model number.
                deviceInfoViewController?.modelNumberLabel.text = deviceInfo as? String
            case ABTBluetoothReaderDeviceInfoSerialNumberString:
                // Show the serial number.
                deviceInfoViewController?.serialNumberLabel.text = deviceInfo as? String
            case ABTBluetoothReaderDeviceInfoFirmwareRevisionString:
                // Show the firmware revision.
                deviceInfoViewController?.firmwareRevisionLabel.text = deviceInfo as? String
            case ABTBluetoothReaderDeviceInfoHardwareRevisionString:
                // Show the hardware revision.
                deviceInfoViewController?.hardwareRevisionLabel.text = deviceInfo as? String
            case ABTBluetoothReaderDeviceInfoManufacturerNameString:
                // Show the manufacturer name.
                deviceInfoViewController?.manufacturerNameLabel.text = deviceInfo as? String
            default:
                break
            }
            deviceInfoViewController?.tableView.reloadData()
        }

    }
   

    
    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didAuthenticateWithError error: Error?) {
        
        debugPrint("### didAuthenticateWithError ... ")
        
        //abd_showError(error: error as!NSError)
        showAlert(title:"Information", content:"The reader is authenticated successfully.")
       
    }

    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didReturnAtr atr: Data!, error: Error?) {

         debugPrint("### didReturnAtr ... ")
        

        // Show the ATR string.
        atrLabel.text = ABDHex.hexString(fromByteArray: atr)
        tableView.reloadData()
        
    }
    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didPowerOffCardWithError error: Error?) {
        debugPrint("### didPowerOffCardWithError ... ")
    }


    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didReturnCardStatus cardStatus: UInt, error: Error?) {

        debugPrint("### didReturnCardStatus ... ")
        

        // Show the card status.
        cardStatusLabel.text = abd_string(cardStatus: cardStatus)
        tableView.reloadData()
     
    }
    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didReturnResponseApdu apdu: Data!, error: Error) {
        debugPrint("### didReturnResponseApdu ... ")
    }
    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didReturnEscapeResponse response: Data!, error: Error) {
        debugPrint("### didReturnEscapeResponse ... ")
        debugPrint(response)
    }
    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didChangeCardStatus cardStatus: UInt, error: Error) {
        debugPrint("### didChangeCardStatus ... ")
        debugPrint(cardStatus)
    }
    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader, didChangeBatteryLevel batteryLevel: UInt, error: Error) {
        debugPrint("### didChangeBatteryLevel ... ")
        // Show the battery level.
        batteryLevelLabel.text = "\(Int(batteryLevel))%"
        tableView.reloadData()
    }
    func bluetoothReader(_ bluetoothReader: ABTBluetoothReader!, didChangeBatteryStatus batteryStatus: UInt, error: Error!) {
        debugPrint("### didChangeBatteryStatus ... ")
        // Show the battery status.
        self.batteryStatusLabel.text = abd_string(batteryStatus: batteryStatus)//[self ABD_stringFromBatteryStatus:batteryStatus];
        tableView.reloadData()
    }

        
    func abd_string(cardStatus: ABTBluetoothReaderCardStatus) -> String {
        var string: String? = nil
        switch Int(cardStatus) {
        case ABTBluetoothReaderCardStatusUnknown:
            string = "Unknown"
        case ABTBluetoothReaderCardStatusAbsent:
            string = "Absent"
        case ABTBluetoothReaderCardStatusPresent:
            string = "Present"
        case ABTBluetoothReaderCardStatusPowered:
            string = "Powered"
        case ABTBluetoothReaderCardStatusPowerSavingMode:
            string = "Power Saving Mode"
        default:
            string = "Unknown"
        }
        return string ?? ""
    }

    /**
     * Returns the description from the battery status.
     * @param batteryStatus the battery status.
     * @return the description.
     */
    func abd_string(batteryStatus: ABTBluetoothReaderBatteryStatus) -> String {
        var string: String? = nil
        switch Int(batteryStatus) {
        case ABTBluetoothReaderBatteryStatusNone:
            string = "No Battery"
        case ABTBluetoothReaderBatteryStatusFull:
            string = "Full"
        case ABTBluetoothReaderBatteryStatusUsbPlugged:
            string = "USB Plugged"
        default:
            string = "Low"
        }
        return string ?? ""
    }
    
    /**
     * Shows the error.
     * @param error the error.
     */
    func abd_showError(error:NSError)  {
     
        let alertError = UIAlertController(title: "Error \(Int(error.code))", message: error.localizedDescription, preferredStyle: .alert)
        alertError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertError, animated: true, completion: nil)

    }
    
    /**
     * Shows message.
     * @param title the title.
     */
    func showAlert (title:String, content:String)  {
    
        let alertError = UIAlertController(title: title, message: content, preferredStyle: .alert)
        alertError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertError, animated: true, completion: nil)
    }
    
    
  
}
