//
//  Countries.swift
//  Assignment
//
//  Created by Govardhan Singh on 13/03/24.
//

import Foundation


struct Country: Codable {
    let name: String?
    let code: String?
}

struct Countries {
    let list: [Country]
    
    static func getCountry() -> [Country] {
        return [Country(name: "Argentina", code: "ar"),
                Country(name: "Australia", code: "au"),
                Country(name: "Austria", code: "at"),
                Country(name: "Belgium", code: "be"),
                Country(name: "Brazil", code: "br"),
                Country(name: "Bulgaria", code: "bg"),
                Country(name: "Canada", code: "ca"),
                Country(name: "China", code: "cn"),
                Country(name: "Colombia", code: "co"),
                Country(name: "Cuba", code: "cu"),
                Country(name: "Czech Republic", code: "cz"),
                Country(name: "Egypt", code: "eg"),
                Country(name: "France", code: "fr"),
                Country(name: "Germany", code: "de"),
                Country(name: "Greece", code: "gr"),
                Country(name: "Hong Kong", code: "hk"),
                Country(name: "Hungry", code: "hu"),
                Country(name: "India", code: "in"),
                Country(name: "Indonesia", code: "id"),
                Country(name: "Ireland", code: "ie"),
                Country(name: "Israel", code: "il"),
                Country(name: "Italy", code: "it"),
                Country(name: "Japan", code: "jp"),
                Country(name: "Latvia", code: "lv"),
                Country(name: "Lithuania", code: "lt"),
                Country(name: "Malaysia", code: "my"),
                Country(name: "Mexico", code: "mx"),
                Country(name: "Moroco", code: "ma"),
                Country(name: "Netherlands", code: "nl"),
                Country(name: "New Zealand", code: "nz"),
                Country(name: "Nigeria", code: "ng"),
                Country(name: "Norway", code: "no"),
                Country(name: "Philippines", code: "ph"),
                Country(name: "Poland", code: "pl"),
                Country(name: "Portugal", code: "pt"),
                Country(name: "Romania", code: "ro"),
                Country(name: "Russia", code: "ru"),
                Country(name: "Saudi Arabia", code: "sa"),
                Country(name: "Serbia", code: "rs"),
                Country(name: "Singapore", code: "sg"),
                Country(name: "Slovakia", code: "sk"),
                Country(name: "Slovenia", code: "si"),
                Country(name: "South Africa", code: "za"),
                Country(name: "South Korea", code: "kr"),
                Country(name: "Swedan", code: "se"),
                Country(name: "SwitzerLand", code: "ch"),
                Country(name: "Taiwan", code: "tw"),
                Country(name: "Thailand", code: "th"),
                Country(name: "Turkey", code: "tr"),
                Country(name: "UAE", code: "ae"),
                Country(name: "Ukraine", code: "ua"),
                Country(name: "United Kingdom", code: "gb"),
                Country(name: "United States", code: "us"),
                Country(name: "Venuzuela", code: "ve")
        ]
    }
}
