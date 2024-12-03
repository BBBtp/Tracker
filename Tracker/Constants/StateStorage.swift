//
//  StateStorage.swift
//  Tracker
//
//  Created by Богдан Топорин on 03.12.2024.
//

import Foundation

final class StateStorage {
    
    var viewState: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.stateKey)
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: Constants.stateKey)
        }
    }
}
