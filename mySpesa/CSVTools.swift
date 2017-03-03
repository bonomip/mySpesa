//
//  CSVTools.swift
//  mySpesa
//
//  Created by Paolo Bonomi on 01/03/2017.
//  Copyright © 2017 Paolo Bonomi. All rights reserved.
//

import Foundation

@objc (CSVTools)

class CSVTools: NSObject {

    static let data = CSVTools()
    
    // returns URL of CSV file
    func getFile() -> String {
        let fm = FileManager.default
        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let path = docsurl.appendingPathComponent("mySpesa.csv").path
        return path
    }
    
    // this function insert all the products with "numero" > 0 in mySPesa.csv
    func writeCSV(){
        //use ',' to separe data, '\n' to end tupla
        do {
            let data = SQLiteDB.sharedInstance.query(sql: "SELECT * FROM lista WHERE numero > 0")
            var fileData = "Paese,Nome,Valore Facciale,Oncia,Grammi,Quantità,Parziale Grammi\n"
            var t_TotG = 0.0
            for tupla in data {
                //tem var for elemen.value of each tupla
                var t_Ps = ""
                var t_Nme = ""
                var t_VlF = ""
                var t_Oz = ""
                var t_Gr = 0.0
                var t_Nmr = 0
                for element in tupla{
                    if( element.key == "paese" ) { t_Ps = element.value as! String }
                    if( element.key == "nome" ) { t_Nme = element.value as! String }
                    if( element.key == "valoreF" ) { t_VlF = element.value as! String }
                    if( element.key == "oz" ) { t_Oz = element.value as! String }
                    if( element.key == "pesoG" ) { t_Gr = element.value as! Double }
                    if( element.key == "numero" ) { t_Nmr = element.value as! Int }
                }
                fileData += ( t_Ps + "," + t_Nme + "," + t_VlF + "," + t_Oz + "," + String( t_Gr ) + "," + String( t_Nmr ) + "," + String( t_Gr * Double( t_Nmr ) ) + "\n" )
                t_TotG += t_Gr * Double( t_Nmr )
            }
            //add value of total grams
            fileData += " , , , , , , \n\n\t\t\t" + "Totale Grammi: " + String(t_TotG)
            // try write on CSV file
            try fileData.write(toFile: getFile(), atomically: true, encoding: String.Encoding.utf8)
        } catch _ as NSError {
            //if there was an error
            print("\nError while try writing on CSV file")
        }
    }
}
