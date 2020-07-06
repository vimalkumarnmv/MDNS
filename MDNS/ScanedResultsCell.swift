//
//  ScanedResultsCell.swift
//  MDNS
//
//  Created by Vimalkumar on 05/07/20.
//  Copyright © 2020 SMITCH. All rights reserved.
//

import UIKit

class ScanedResultsCell: UITableViewCell {
    @IBOutlet weak var labelContentView: UIView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var serviceType: UILabel!
    @IBOutlet weak var ipAddress: UILabel!
    @IBOutlet weak var portNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelContentView.layer.cornerRadius = 12
        self.labelContentView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setDetails(detail: ScanedResultModel) {
        self.serviceName.setUpText(title: "Name", value: detail.serviceName ?? "")
        self.serviceType.setUpText(title: "Type", value: detail.serviceType ?? "")
        self.ipAddress.setUpText(title: "  IP  ", value: detail.ipAddress ?? "")
        self.portNumber.setUpText(title: "Port", value: detail.portNumber ?? "")
    }
}
