//
//  ViewController.swift
//  mySpesa 2.0
//
//  Created by Paolo Bonomi on 10/02/17.
//  Copyright © 2017 Paolo Bonomi. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var q_Text: UITextField!
    @IBOutlet weak var labelTot: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var pickerDataArray = [[""], [""], [""]]
    var pickerDataPesoG = [0.0, 0.0, 0.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialization of:
            //pickerview
        self.picker.dataSource = self
        self.picker.delegate = self
            //table
        self.table.dataSource = self
        self.table.delegate = self
            //q_text
        self.q_Text.delegate = self
            //headlabel
        headLabel.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0 , green: 215.0/255.0, blue: 0.0/255.0, alpha: 1)
            //labelTot
        labelTot.text = String(Lista.data.getP_TotGrammi())+" gr."
            // pickerdataarray ( used to populate the pickerview )
        pickerDataArray[0] = Lista.data.getFirstArray()
        pickerDataArray[1] = Lista.data.getSecondArray(paese: "America")
        pickerDataArray[2] = Lista.data.getThirdArray(paese: "America", nome: "Aquila")
        pickerDataPesoG = Lista.data.getPesoG(paese: "America", nome: "Aquila")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // PICKER VIEW FUNCTIONS
    
    // this function is called when the pickerview is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if ( component == 0) { // if was changed the first component the second and the third will change too
            // changing the second...
            pickerDataArray[1] = Lista.data.getSecondArray(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)])
            pickerView.reloadComponent(1)
            // changing the third...
            pickerDataArray[2] = Lista.data.getThirdArray(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)], nome: pickerDataArray[1][pickerView.selectedRow(inComponent: 1)])
            // also saving the pesoG data to another array... this is to easly update the db later...
            pickerDataPesoG = Lista.data.getPesoG(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)], nome: pickerDataArray[1][pickerView.selectedRow(inComponent: 1)])
            pickerView.reloadComponent(2)
            
        }
        if ( component == 1 ) { // if was changed only the second component only the third wil change too
            // changing the third...
            pickerDataArray[2] = Lista.data.getThirdArray(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)], nome: pickerDataArray[1][pickerView.selectedRow(inComponent: 1)])
            // also saving the pesoG data to another array like before...
            pickerDataPesoG = Lista.data.getPesoG(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)], nome: pickerDataArray[1][pickerView.selectedRow(inComponent: 1)])
            pickerView.reloadComponent(2)
        }
    }
    
    // number of pickerview's components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerDataArray.count
    }
    
    //number of rows each component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataArray[component].count
    }
    
    // the string displayed for each component's row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataArray[component][row]
    }
    
    // TABLE FUNCTION
    
    // number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return Lista.data.getTableSection().count
    }
    
    // numbers of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Lista.data.getTableP_Name()[section].count
    }
    
    // name for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Lista.data.getTableSection()[section]
    }
    
    // populate the table view and choose the syle for the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "ProductCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell( style: .subtitle, reuseIdentifier: cellID )
        // style of each cell
        cell.detailTextLabel?.text = Lista.data.getTableP_Info()[indexPath.section][indexPath.row]
        cell.textLabel?.text = Lista.data.getTableP_Name()[indexPath.section][indexPath.row]
        return cell
    }
    
    // this function enable editing rows in the table
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // this function is called when the user want to delete a row in the table
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) { // if the user press delete
            if( Lista.data.updateP_Number( paese: Lista.data.getTableSection()[indexPath.section], nome: Lista.data.getTableP_Name()[indexPath.section][indexPath.row], pesoG: Lista.data.getTableP_PesoG()[indexPath.section][indexPath.row], numero: 0) == 0 ){ // there was an error
            }
            else { //update data table correctly
                updateTable()
            }
        }
    }
    
    // this function update the data of the table
    func updateTable() {
        table.reloadData()
        labelTot.text = String(Lista.data.getP_TotGrammi())
    }
    
    
    // STEPPER FUNCTION
    
    //setting the text of TextField with the UIStepper value (from -100 to 100)
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        q_Text.text = String(Int(sender.value))
    }
    
    // BUTTON CONFRMA FUNCTION
    
    // function called when button 'conferma' is pressed
    @IBAction func confermaPressed(_ sender: UIButton) {
        // the value of the TextField must be of only decimal digits
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: q_Text.text!)
        // if the text is composed by decimal digits and is not equal to 0 and isn't empty...
        if(allowedCharacters.isSuperset(of: characterSet) && Int(q_Text.text!) != 0 && !(q_Text.text?.isEmpty)!) {
            // update column number in the db data.db
            if(Lista.data.updateP_Number(paese: pickerDataArray[0][picker.selectedRow(inComponent: 0)], nome: pickerDataArray[1][picker.selectedRow(inComponent: 1)], pesoG: pickerDataPesoG[picker.selectedRow(inComponent: 2)], numero: Int(q_Text.text!)!) == 0) { // if there was an error upgrading the number value...
                
                // do stuff...
                
            }
            else { // update db correctly
                // update table
                updateTable()
            }
        }
        else { // else text isn't in a correct format
            // display error
            q_Text.text = "errore"
        }
    }
    
    //function to hide keybord when pressing " conferma "
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // BUTTON RESET FUNCTION
    
    // DB function // set the number of all to 0
    @IBAction func resetPressed(_ sender: UIButton) {
        _ = SQLiteDB.sharedInstance.execute(sql: "UPDATE lista SET numero=0")
        updateTable()
        q_Text.text = "0"
        stepper.value = 0.0
    }
    
    // SEND MAIL FUNCTION
    
    // this function hendle the event of the button "invia"
    @IBAction func sendEmail(_ sender: UIButton) {
        
        // set up date
        let day = Calendar.current.component(.day, from: NSDate() as Date)
        let month = Calendar.current.component(.month, from: NSDate() as Date)
        let year = Calendar.current.component(.year, from: NSDate() as Date)
        let hour = Calendar.current.component(.hour, from: NSDate() as Date)
        let minute = Calendar.current.component(.minute, from: NSDate() as Date)
        
        if( MFMailComposeViewController.canSendMail() ) { // if is possible to send email
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["info@euronummus.it"])
            mail.setSubject("Lista della spesa " + "[ \(day)/\(month)/\(year) \(hour):\(minute) ]")
            mail.setMessageBody(Lista.data.P_toString(), isHTML: false)
            present(mail, animated: true)
        }
        else { // else is impossible to send an email
            // do stuff
        }
    }
    
    // function to dismiss the mail window
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


