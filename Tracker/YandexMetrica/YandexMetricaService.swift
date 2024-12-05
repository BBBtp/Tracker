
//
//  YandexMetricaService.swift
//  Tracker
//
//  Created by Богдан Топорин on 05.12.2024.
//

import Foundation
import YandexMobileMetrica

struct YandexMetricaService {
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "4dba3818-b60d-4a14-a315-abd4b0a2d3ec") else { return }

        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
