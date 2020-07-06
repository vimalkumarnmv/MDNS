//
//  ViewController.swift
//  MDNS
//
//  Created by Vimalkumar on 05/07/20.
//  Copyright © 2020 SMITCH. All rights reserved.
//

import UIKit
import Network
class ViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var publish: UIButton!
    @IBOutlet weak var scan: UIButton!
    @IBOutlet weak var scanedResults: UITableView!
    @IBOutlet weak var noResultMessage: UILabel!
    //MARK: Variables
    var netServicePublish = NetService()
    var netServiceBrowserScan = NetServiceBrowser()
    var isNetServicePublishing: Bool!
    var isNetServiceBrowserScaning: Bool!
    //To store the avilable services
    var services: [NetService] = []  {
        didSet {
            self.setUpResolvedServices()
        }
    }
    //To store the table datas
    var resolvedServices : [ScanedResultModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Initial setup
        self.pageSetup()
    }
    //To setup Page
    func pageSetup() {
        self.view.backgroundColor = .lightText
        //Setup Buttons
        self.publish.layer.cornerRadius = 15.0
        self.publish.clipsToBounds = true
        self.scan.layer.cornerRadius = 15.0
        self.scan.clipsToBounds = true
        
        self.animateButton(sender: publish)
        self.animateButton(sender: scan)
        
        //Createing a NetService to Publish
        self.netServicePublish = NetService.init(domain: NETSERVICE.domain, type: NETSERVICE.type, name: NETSERVICE.name, port: NETSERVICE.port)
        self.netServicePublish.delegate = self
        
        //Creating a NetServiceBrowser to Scan
        self.netServiceBrowserScan = NetServiceBrowser.init()
        self.netServiceBrowserScan.delegate = self
        
        //TableView Setup
        self.scanedResults.rowHeight = UITableView.automaticDimension
        self.scanedResults.estimatedRowHeight = 700
        self.scanedResults.delegate = self
        self.scanedResults.dataSource = self
        self.scanedResults.showsVerticalScrollIndicator = false
        self.scanedResults.separatorStyle = .none
        self.scanedResults.layer.cornerRadius = 10.0
    }
    @IBAction func publishAction(_ sender: UIButton) {
        netServicePublish.publish()
    }
    @IBAction func scanAction(_ sender: UIButton) {
        netServiceBrowserScan.includesPeerToPeer = true
        netServiceBrowserScan.searchForServices(ofType: NETSERVICE.type, inDomain: NETSERVICE.domain)
        netServiceBrowserScan.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        self.noResultMessage.text = "No Results Found. Scanning..."
    }
}
//MARK: Common Functions
extension ViewController {
    //To check the resolved status
    func updateServices() {
        for service in self.services {
            if service.port == -1 {
                print("service \(service.name) of type \(service.type)" +
                    " not yet resolved")
                service.delegate = self
                service.resolve(withTimeout: 5.0)
            }
        }
    }
    
    //Setup the data for TableView
    func setUpResolvedServices() {
        self.resolvedServices.removeAll()
        for service in self.services {
            if service.port != -1 {
                let address = self.convertIPAddress(datas: service.addresses ?? [])
                let resolvedSerivceObj = ScanedResultModel.init(serviceName: service.name, serviceType: service.type, ipAddress: "\(address)", portNumber: "\(service.port)", netService: service)
                self.resolvedServices.append(resolvedSerivceObj)
            }
        }
        self.scanedResults.reloadData()
    }
    // MARK:- Convert IP Address form Data
    func convertIPAddress(datas:[Data]) -> String {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        for data in datas {
            data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
                let sockaddrPtr = pointer.bindMemory(to: sockaddr.self)
                guard let unsafePtr = sockaddrPtr.baseAddress else { return }
                guard getnameinfo(unsafePtr, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                    return
                }
            }
            let ipAddress = String(cString:hostname)
            if let _ = IPv4Address(ipAddress) {
                if ipAddress != "127.0.0.1" {
                    return ipAddress
                }
            }
        }
        return ""
    }
    //To animate button
    func animateButton(sender: UIButton) {

        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 2.0,
                                   delay: 0,
                                   usingSpringWithDamping: CGFloat(0.20),
                                   initialSpringVelocity: CGFloat(6.0),
                                   options: UIView.AnimationOptions.allowUserInteraction,
                                   animations: {
                                    sender.transform = CGAffineTransform.identity
            },
                                   completion: { Void in()  }
        )
    }
}
//MARK: TableView Delegate and DataSources
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noResultMessage.isHidden = resolvedServices.count != 0
        return resolvedServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ScanedResultsCell! = tableView.dequeueReusableCell(withIdentifier: "ScanedResultsCell", for: indexPath) as? ScanedResultsCell
        cell.selectionStyle = .none
        cell.setDetails(detail: resolvedServices[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let netservice =  resolvedServices[indexPath.row].netService {
            netservice.stop()
        }
    }
}

//MARK: NetServiceBrowser Delegate
extension ViewController : NetServiceBrowserDelegate {
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("netServiceBrowserWillSearch : \(browser)")
    }
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("netServiceBrowserDidStopSearch")
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("didNotSearch : \(browser) errorDict:\(errorDict)")
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("didFind")
        self.services.append(service)
        self.updateServices()
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("didRemove")
        if let ix = self.services.firstIndex(of: service) {
            self.services.remove(at: ix)
        }
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        print("didFindDomain : \(browser) domainString:\(domainString) moreComing:\(moreComing)")
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        print("didRemoveDomain")
    }
}

//MARK: NetService Delegate
extension ViewController : NetServiceDelegate {
    func netServiceDidStop(_ sender: NetService) {
        print("netServiceDidStop")
    }
    func netServiceDidPublish(_ sender: NetService) {
        print("netServiceDidPublish : \(sender)")
    }
    func netServiceWillPublish(_ sender: NetService) {
        print("netServiceWillPublish : \(sender)")
    }
    func netServiceWillResolve(_ sender: NetService) {
        print("netServiceWillResolve")
    }
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("netServiceDidResolveAddress")
        if let ix = self.services.firstIndex(of: sender) {
            self.services.remove(at: ix)
            self.services.insert(sender, at: ix)
        }
    }
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("didNotPublish errorDict: \(errorDict)")
        
    }
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("didNotResolve errorDict: \(errorDict)")
        
    }
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        print("didAcceptConnectionWith")
    }
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        print("didUpdateTXTRecord")
        
    }
}
