//
//  ViewController.swift
//  mySpesa 2.0
//
//  Created by Paolo Bonomi on 10/02/17.
//  Copyright © 2017 Paolo Bonomi. All rights reserved.
//

import UIKit
import MessageUI
import Foundation

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    
    //label that display mySpesa title in the View
    @IBOutlet weak var headLabel: UILabel!
    //pickerview used to select product
    @IBOutlet weak var picker: UIPickerView!
    //table used to display product with DB 'numero' > 0
    @IBOutlet weak var table: UITableView!
    //text which the user can choose the quantity for each product selected by the pickerview
    @IBOutlet weak var q_Text: UITextField!
    //label display the sum of DB 'pesoG' * 'numero' for each product with 'numero' > 0
    @IBOutlet weak var labelTot: UILabel!
    // stepper used to fill q_Text
    @IBOutlet weak var stepper: UIStepper!
    
    //array used to reference the pickerview
    var pickerDataArray = [[""], [""], [""]]
    //array used to update the DB to avoid possibily mistake with casting
    // ( from Double to String [need by pickerview third component] and from String to Double [need by DB query SELECT to update the column 'numero'] )
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
        headLabel.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0 , green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
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
    
    // this function is called when the pickerview is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if ( component == 0) { // if was changed first component so second and third will change too
            // changing second...
            pickerDataArray[1] = Lista.data.getSecondArray(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)])
            pickerView.reloadComponent(1)
            // changing third...
            pickerDataArray[2] = Lista.data.getThirdArray(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)], nome: pickerDataArray[1][pickerView.selectedRow(inComponent: 1)])
            // also saving DB 'pesoG' data to another array... this is to easly update column 'numero' in DB later...
            pickerDataPesoG = Lista.data.getPesoG(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)], nome: pickerDataArray[1][pickerView.selectedRow(inComponent: 1)])
            pickerView.reloadComponent(2)
            
        }
        if ( component == 1 ) { // if was changed second component only third wil change too
            // changing third...
            pickerDataArray[2] = Lista.data.getThirdArray(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)], nome: pickerDataArray[1][pickerView.selectedRow(inComponent: 1)])
            // also saving DB 'pesoG' data to another array... this is to easly update column 'numero' in DB later...
            pickerDataPesoG = Lista.data.getPesoG(paese: pickerDataArray[0][pickerView.selectedRow(inComponent: 0)], nome: pickerDataArray[1][pickerView.selectedRow(inComponent: 1)])
            pickerView.reloadComponent(2)
        }
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
    
    // enable editing rows in the table
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // this function is called when a row in the table was swipe to the left
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) { // if the user press delete
            //update DB changing the DB 'numero' to 0
            if( Lista.data.updateP_Number( paese: Lista.data.getTableSection()[indexPath.section], nome: Lista.data.getTableP_Name()[indexPath.section][indexPath.row], pesoG: Lista.data.getTableP_PesoG()[indexPath.section][indexPath.row], numero: 0) == 0 ){
                // there was an error updating DB
                print("Error updating DB - While try to delete a row in the table the update method fails")
            }
            else {
                //the DB was update correclty so also update data table
                updateTable()
            }
        }
    }
    
    // this function choose how populate the table view and populate it with the choosen syle
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //this is need to release memory
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") ?? UITableViewCell( style: .subtitle, reuseIdentifier: "ProductCell")
        // style of each cell
        // textLabel will show DB 'name' attribute
        cell.textLabel?.text = Lista.data.getTableP_Name()[indexPath.section][indexPath.row]
        // datailTextLabel will show DB 'valoreF', 'oz', 'pesoG', 'numero' and 'pesoG'*'numero' as 'Parziale Grammi'
        cell.detailTextLabel?.text = Lista.data.getTableP_Info()[indexPath.section][indexPath.row]
        return cell
    }
    
    // this function update the data of the table
    func updateTable() {
        table.reloadData()
        //also update the labelTot that shows the sum of all DB products 'pesoG'*'numero' with 'numero' > 0
        labelTot.text = String(Lista.data.getP_TotGrammi())
    }
    
// STEPPER FUNCTION
    
    // call when user press stepper
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        //change text of TextField with UIStepper value (from 0 to 100)
        q_Text.text = String(Int(sender.value))
    }
    
// BUTTON ADD FUNCTION
    
    // function called when button 'add' is pressed
    @IBAction func AddPressed(_ sender: UIButton) {
        if(CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: q_Text.text!)) && Int(q_Text.text!) != 0 && !(q_Text.text?.isEmpty)!) {
            // if q_Text.text is in decimal digits and isn't 0 and isn't empty...
            // update column DB 'number'
            if(Lista.data.updateP_Number(paese: pickerDataArray[0][picker.selectedRow(inComponent: 0)], nome: pickerDataArray[1][picker.selectedRow(inComponent: 1)], pesoG: pickerDataPesoG[picker.selectedRow(inComponent: 2)], numero: Int(q_Text.text!)!) == 0) {
                // there was an error updating DB
                print("Error updating DB - Impossible to update column 'numero'")
            }
            else {
                //the DB was update correclty so also update data table
                updateTable()
            }
        }
        else {
            // if q_Text.text isn't in decimal digits or is 0 or is empty... display error in q_Text
            q_Text.text = "ERR"
        }
    }
    
    // this function hide keybord when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
// BUTTON RESET FUNCTION
    
    // DB function // this function is called when button 'reset' is pressed
    @IBAction func resetPressed(_ sender: UIButton) {
        //set DB 'numero' of all products to 0
        _ = SQLiteDB.sharedInstance.execute(sql: "UPDATE lista SET numero=0")
        //update table
        updateTable()
        //set q_Text to 0
        q_Text.text = "0"
        //set stepper.value to 0.0
        stepper.value = 0.0
    }
    
// SEND MAIL FUNCTION
    
    // this function is called when button 'invia' is pressed
    @IBAction func sendEmail(_ sender: UIButton) {
        
        //write on CSV file all the products with DB 'numero' > 0
        CSVTools.data.writeCSV()
        
        // set up date DD/MM/YYYY HH:MM
        let day = Calendar.current.component(.day, from: NSDate() as Date)
        let month = Calendar.current.component(.month, from: NSDate() as Date)
        let year = Calendar.current.component(.year, from: NSDate() as Date)
        let hour = Calendar.current.component(.hour, from: NSDate() as Date)
        let minute = Calendar.current.component(.minute, from: NSDate() as Date)
        
        if( MFMailComposeViewController.canSendMail() ) {
            // if is possible to send email
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            // set recipient
            mail.setToRecipients(["info@euronummus.it"])
            //set subject
            mail.setSubject("Lista della spesa " + "[ \(day)/\(month)/\(year) \(hour):\(minute) ]")
            //set message body
            mail.setMessageBody("\n\n\t\t\t Aprire il file allegato tramite Excel \n\n\n", isHTML: false)
            do{
                // try to attach CSV file
                try mail.addAttachmentData( NSData( contentsOfFile: CSVTools.data.getFile() ) as Data, mimeType: "text/csv", fileName: "mySpesa")
            } catch _ as NSError {
                //if there was an error attaching the CSV file
                print("\nErrore nell'invio dell'allegato")
            }
            //send mail
            present(mail, animated: true)
        }
        else { // else is impossible to send an email
            // do stuff
            print("\nImpossibile inviare Mail")
        }
    }
    
    // this function dismiss the mail window once it is sent
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


