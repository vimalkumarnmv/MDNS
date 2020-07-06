//
//  Extensions.swift
//  MDNS
//
//  Created by Vimalkumar on 05/07/20.
//  Copyright © 2020 SMITCH. All rights reserved.
//

import Foundation
import UIKit

struct NETSERVICE {
    static let type = "_http._tcp."
    static let name = UIDevice.current.name
    static let domain = "local."
    static let port: Int32 = 8080
}

class ScanedResultModel {
    var serviceName: String!
    var serviceType: String!
    var ipAddress: String!
    var portNumber: String!
    var netService: NetService!
    init(serviceName: String, serviceType: String, ipAddress: String, portNumber: String, netService: NetService) {
        self.serviceName = serviceName
        self.serviceType = serviceType
        self.ipAddress = ipAddress
        self.portNumber = portNumber
        self.netService = netService
    }
    init() {
    }
}

extension UILabel {
    func setUpText(title: String, value: String) {
        let titleAtribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Helvetica-Bold", size: 16.0) ?? UIFont.boldSystemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor : UIColor.black]
        let valueAtribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 16.0) ?? UIFont.systemFont(ofSize: 12.0) , NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        
        let formattedString = NSMutableAttributedString(string: "")
        let titleString = NSMutableAttributedString(string: title, attributes: titleAtribute)
        formattedString.append(titleString)
        formattedString.append(NSAttributedString(string: "\t: "))
        
        let valueString = NSMutableAttributedString(string: value, attributes: valueAtribute)
        formattedString.append(valueString)
        self.text = ""
        self.attributedText = formattedString
    }
}
