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
    
    let filename = "mySpesa"
    let typeOfFile = "csv"
    static let data = CSVTools()
    
    // returns the URL of the CSV file
    func getFile() -> String {
        return Bundle.main.path(forResource: self.filename, ofType: self.typeOfFile)!
    }
    
    // this method write inside the CSV file the data of the product with "numero" > 0
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
            //add the value of total grams
            fileData += "\n\n\t\t\t" + "Totale Grammi: " + String(t_TotG)
            // Write on CSV
            try fileData.write(toFile: getFile(), atomically: true, encoding: String.Encoding.utf8)
        } catch _ as NSError { print("Error while try writing on CSV file") }

        //DEBUG PRINT CSV FILE
        do { try print( String(contentsOfFile: getFile(), encoding: String.Encoding.utf8 )) } catch _ as NSError { print("Error while print CSV file") }
    }
}
