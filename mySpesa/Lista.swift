//
//  Lista.swift
//  mySpesa
//
//  Created by Paolo Bonomi on 25/02/2017.
//  Copyright © 2017 Paolo Bonomi. All rights reserved.
//

import Foundation

@objc(Lista)
class Lista: NSObject {
    
   static let data = Lista()
    
// function that operate to the db excluding the column NUMERO
    
    // DB function // First component of picker view // do a select return the column paese from lista
    func getFirstArray() -> [String] {
        let dataPaese = SQLiteDB.sharedInstance.query(sql: "SELECT DISTINCT paese FROM lista")
        var arrayPaese = [String]()
        for array in dataPaese {
            for element in array {
                arrayPaese.append(element.value as! String)
            }
        }
        // returns a sorted array from distinct values in paese
        return arrayPaese.sorted() }
    
    // DB function // Second component of picker view //do a select return the column nome from lista
    func getSecondArray(paese: String) -> [String] {
        // paese is the element choosen from the first component of the picker view...
        let dataNome = SQLiteDB.sharedInstance.query(sql: "SELECT DISTINCT nome FROM lista WHERE paese='\(paese)'")
        var arrayNome = [String]()
        for array in dataNome {
            for element in array {
                arrayNome.append(element.value as! String)
            }
        }
        // returns a sorted array from distinct values present in nome
        return arrayNome.sorted() }
    
    // DB function // Third component of picker view //do a select return the column valoreF, oz, pesoG from lista
    func getThirdArray(paese: String, nome: String) -> [String] {
        // paese is the element choosen from the first component of the picker view
        // nome is the element choosen from the second component of the picker view
        let dataSpecifica = SQLiteDB.sharedInstance.query(sql: "SELECT valoreF, oz FROM lista WHERE paese='\(paese)' AND nome ='\(nome)'")
        var arraySpecifica = [String]()
        var temp = ""
        var vf = ""
        var oz = ""
        for array in dataSpecifica {
            for element in array {
                if( element.key == "valoreF" ) { vf = element.value as! String}
                if( element.key == "oz") { oz = element.value as! String}
            }
            temp = vf + " | " + oz + " | "
            // arraySpecifica.append(temp) we want the specifica from bigger to smaller
            arraySpecifica.insert(temp, at: 0)
            temp = ""
        }
        let dataPesoG = SQLiteDB.sharedInstance.query(sql: "SELECT pesoG FROM lista WHERE paese='\(paese)' AND nome='\(nome)'")
        var i = arraySpecifica.count-1
        for array in dataPesoG {
            for element in array {
                arraySpecifica[i] += String(format: "%.2f", (element.value as! Double)) + "g "
                i -= 1
            }
        }
        // return an array es: " 100$ | 1 oz | 31.10g "
        return arraySpecifica }
    
    // DB function // do a select return the column pesoG from lista
    func getPesoG(paese: String, nome: String) -> [Double] {
        // complementary to getThirdArray
        // this function returns an array of Double of pesoG
        let dataPesoG = SQLiteDB.sharedInstance.query(sql: "SELECT pesoG FROM lista WHERE paese='\(paese)' AND nome ='\(nome)'")
        var arrayPesoG = [Double]()
        for array in dataPesoG {
            for element in array {
                // array.PesoG.append( element.value as! Double ) we want peso from bigger to smaller
                arrayPesoG.insert((element.value as! Double), at: 0)
            }
        }
        // returns an array of double
        return arrayPesoG }
    
// function that operate on the db including the column NUMERO
    
    // DB function // returns an array used to fill table's selection
    func getTableSection() -> [String] {
        let dataSelection = SQLiteDB.sharedInstance.query(sql: "SELECT DISTINCT paese FROM lista WHERE numero > 0")
        var arraySelection = [String]()
        for array in dataSelection{
            for element in array{
                arraySelection.append(element.value as! String)
            }
        }
        return arraySelection.sorted() }
    
    // DB function // this function return the name of the coin that have numero > 0 group by paese
    func getTableP_Name() -> [[String]] {
        var arrayNome = [[String]]()
        for paese in getTableSection() { //for each paese in section
            let dataNome = SQLiteDB.sharedInstance.query(sql: "SELECT nome FROM lista WHERE paese='\(paese)' AND numero > 0")
            var temp = [String]()
            for tupla in dataNome { //for each tupla in data nome
                for nome in tupla { //for each nome
                    temp.append(nome.value as! String)
                }
            }
            arrayNome.append(temp)
        }
        return arrayNome }
    
    // DB function // function returns info ( valoreF, oz, pesoG, numero, pesoG*numero ) of the coin that have numero > 0 group by paese
    func getTableP_Info() -> [[String]] {
        var arrayInfo = [[String]]()
        for paese in getTableSection(){ //for each paese in section
            let dataInfo = SQLiteDB.sharedInstance.query(sql: "SELECT valoreF, oz, pesoG, numero FROM lista WHERE paese='\(paese)' AND numero > 0")
            var tempArray = [String]()
            for tupla in dataInfo{ //for each tupla in data info
                var temp = ""
                var tempPeso = 0.0
                var tempNumero = 0.0
                var tempValoreF = ""
                var tempOz = ""
                for info in tupla{ // for each info in tupla
                    if(info.key == "pesoG") { tempPeso = info.value as! Double }
                    if(info.key == "numero") { tempNumero = Double(info.value as! Int) }
                    if(info.key == "valoreF") { tempValoreF = info.value as! String }
                    if(info.key == "oz") { tempOz = info.value as! String }
                }
                temp = " Valore Facciale: \(tempValoreF) | Oncia: \(tempOz) | Grammi: \(tempPeso) | Quantità: \(Int(tempNumero)) | Parziale Grammi: \(tempPeso*tempNumero)"
                //tempArray.append(temp) we want bigger to smaller
                tempArray.insert(temp, at: 0)
            }
            arrayInfo.append(tempArray)
        }
        return arrayInfo }
    
    // DB function // this function is needed by the "swipeDeleteRowTable"
    func getTableP_PesoG() -> [[Double]] {
        var arrayPeso = [[Double]]()
        for paese in getTableSection() { //for each header paese
            let dataPeso = SQLiteDB.sharedInstance.query(sql: "SELECT pesoG FROM lista WHERE paese='\(paese)' AND numero > 0")
            var temp = [Double]()
            for tupla in dataPeso{
                for peso in tupla{
                    temp.append(peso.value as! Double)
                }
            }
            arrayPeso.append(temp)
        }
        return arrayPeso }
    
    // DB function // this function return a formatted string contains all the product with numero > 0
    func P_toString() -> String{
        
        let dataProducts = SQLiteDB.sharedInstance.query(sql: "SELECT * FROM lista WHERE numero > 0")
        var prodotti = "\n\n"
        var totGrammi = 0.0
        
        for array in dataProducts{
            var tempPaese = ""
            var tempNome = ""
            var tempFacc = ""
            var tempOz = ""
            var tempPeso = 0.0
            var tempNumero = 0
            for element in array{
                if(element.key == "paese") {tempPaese = element.value as! String}
                if(element.key == "nome") {tempNome = element.value as! String}
                if(element.key == "valoreF") { tempFacc = element.value as! String}
                if(element.key == "oz") {tempOz = element.value as! String}
                if(element.key == "pesoG") {tempPeso = element.value as! Double}
                if(element.key == "numero") {tempNumero = element.value as! Int}
            }
            prodotti += "Paese: " + tempPaese + "\n" +
                        "Nome: " + tempNome + "\n" +
                        "Valore Facciale: " + tempFacc + "\n" +
                        "Oncia: " + tempOz + "\n" +
                        "Grammi: " + String(tempPeso) + " \n " +
                        "Quantità: " + String(tempNumero) + "\n" +
                        "Parizale Grammi: " + String(tempPeso*Double(tempNumero)) + "\n\n"
            
            totGrammi += tempPeso*Double(tempNumero)
        }
        return prodotti + "\n TOTALE GRAMMI: " + String(totGrammi)
    }
    
    // DB function // returns the sum of all products parizale_grammi ( parziale_grammi = grammi*numero )
    func getP_TotGrammi() -> Double {
        let dataGrammi = SQLiteDB.sharedInstance.query(sql: "SELECT pesoG, numero FROM lista WHERE numero > 0")
        var sum = 0.0
        var tempG = 0.0
        var tempN = 0.0
        
        for tupla in dataGrammi{
            for element in tupla {
                if( element.key == "pesoG" ) { tempG = element.value as! Double }
                if( element.key == "numero" ) { tempN = Double(element.value as! Int) }
            }
            sum += tempG*tempN
        }
        
        return sum }
    
    // DB function // update the column 'numero'
    func updateP_Number( paese: String, nome: String, pesoG: Double, numero: Int ) -> CInt {
        return SQLiteDB.sharedInstance.execute(sql: "UPDATE lista SET numero=\(numero) WHERE paese='\(paese)' AND nome='\(nome)' AND pesoG=\(pesoG)") }
}
