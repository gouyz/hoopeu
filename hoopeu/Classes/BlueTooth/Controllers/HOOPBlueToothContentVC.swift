//
//  HOOPBlueToothContentVC.swift
//  hoopeu
//  蓝牙连接
//  Created by gouyz on 2019/3/24.
//  Copyright © 2019 gyz. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreBluetooth

private let blueToothContentCell = "blueToothContentCell"

class HOOPBlueToothContentVC: GYZBaseVC {
    //中心对象
    var manager: CBCentralManager?
    // 当前连接的设备
    var currentPeripheral: CBPeripheral?
    //保存收到的蓝牙设备
    var deviceList:[CBPeripheral] = [CBPeripheral]()
    //保存收到的蓝牙设备名称
    var deviceNameList:[String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "连接蓝牙"
        self.view.backgroundColor = kWhiteColor
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.setTitle("刷新", for: .normal)
        rightBtn.titleLabel?.font = k15Font
        rightBtn.setTitleColor(kBlueFontColor, for: .normal)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: kTitleHeight, height: kTitleHeight)
        rightBtn.addTarget(self, action: #selector(onClickRightBtn), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
        
        setUpUI()
        //1.创建一个中央对象
        self.manager = CBCentralManager.init(delegate: self, queue: nil)
    }
    func setUpUI(){
        view.addSubview(desLab)
        view.addSubview(desLab1)
        view.addSubview(tableView)
        view.addSubview(questionBtn)
        
        desLab.snp.makeConstraints { (make) in
            make.left.equalTo(kMargin)
            make.right.equalTo(-kMargin)
            make.top.equalTo(kTitleAndStateHeight + kTitleHeight)
            make.height.equalTo(50)
        }
        desLab1.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.top.equalTo(desLab.snp.bottom)
            make.height.equalTo(kTitleHeight)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(desLab1.snp.bottom)
            make.bottom.equalTo(questionBtn.snp.top).offset(-kMargin)
        }
        questionBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(desLab)
            make.bottom.equalTo(-kTitleHeight)
            make.height.equalTo(kBottomTabbarHeight)
        }
    }
    lazy var desLab : UILabel = {
        let lab = UILabel()
        lab.font = k18Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "开启蓝牙"
        
        return lab
    }()
    lazy var desLab1 : UILabel = {
        let lab = UILabel()
        lab.font = k15Font
        lab.textColor = kBlackFontColor
        lab.textAlignment = .center
        lab.text = "等待连接"
        
        return lab
    }()
    lazy var tableView : UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = kWhiteColor
        
        table.register(HOOPAddVoiceSceneCell.self, forCellReuseIdentifier: blueToothContentCell)
        
        return table
    }()
    
    /// 按钮
    lazy var questionBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = kWhiteColor
        btn.setTitle("列表中没有显示设备名称？", for: .normal)
        btn.setTitleColor(kBlueFontColor, for: .normal)
        btn.titleLabel?.font = k15Font
        
        btn.addTarget(self, action: #selector(clickedQuestionBtn), for: .touchUpInside)
        
        return btn
    }()
    
    ///
    @objc func clickedQuestionBtn(){
        goWebVC()
    }
    /// 列表中没有显示设备名称
    func goWebVC(){
        let vc = JSMWebViewVC()
        vc.webTitle = "列表中没有显示设备名称"
        vc.url = "http://www.hoopeurobot.com/page/protocol.html?id=5"
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 刷新
    @objc func onClickRightBtn(){
        deviceList.removeAll()
        deviceNameList.removeAll()
        tableView.reloadData()
        scanDevice()
    }
    
    func scanDevice(){
        //扫描周边蓝牙外设.
        //写nil表示扫描所有蓝牙外设，如果传上面的kServiceUUID,那么只能扫描出FFEO这个服务的外设。
        //CBCentralManagerScanOptionAllowDuplicatesKey为true表示允许扫到重名，false表示不扫描重名的。
        desLab1.text = "等待连接"
        createHUD(message: "搜索中...")
        self.manager!.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        // 30秒后停止扫描
        startSMSWithDuration(duration: 30)
    }
    
    func goWifiVC(){
        let vc = HOOPConnectWiFiVC()
//        vc.manager = self.manager
        vc.peripheral = self.currentPeripheral
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 倒计时
    ///
    /// - Parameter duration: 倒计时时间
    func startSMSWithDuration(duration:Int){
        var times = duration
        
        let timer:DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue:DispatchQueue.global())
        
        timer.setEventHandler {
            if times > 0{
                DispatchQueue.main.async(execute: {
                    
                    times -= 1
                })
            } else{
                DispatchQueue.main.async(execute: {
                    
                    self.hud?.hide(animated: true)
                    self.desLab1.text = "选择设备"
                    self.manager!.stopScan()
            
                    timer.cancel()
                })
            }
        }
        
        // timer.scheduleOneshot(deadline: .now())
        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        
        timer.resume()
        
        // 在调用DispatchSourceTimer时, 无论设置timer.scheduleOneshot, 还是timer.scheduleRepeating代码 不调用cancel(), 系统会自动调用
        // 另外需要设置全局变量引用, 否则不会调用事件
    }

}
extension HOOPBlueToothContentVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: blueToothContentCell) as! HOOPAddVoiceSceneCell
        
        let device: CBPeripheral = deviceList[indexPath.row]
        
        cell.nameLab.text = deviceNameList[indexPath.row]
        if currentPeripheral?.identifier.uuidString == device.identifier.uuidString {
            cell.nameLab.backgroundColor = kBtnClickBGColor
            cell.nameLab.textColor = kWhiteColor
            cell.nameLab.borderColor = kBtnClickBGColor
        }else {
            cell.nameLab.backgroundColor = kWhiteColor
            cell.nameLab.textColor = kBlackFontColor
            cell.nameLab.borderColor = kBlackFontColor
        }
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentPeripheral = deviceList[indexPath.row]
        createHUD(message: "连接中...")
        self.manager!.connect(currentPeripheral!, options: nil)
    }
    ///MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.000001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.000001
    }
}
extension HOOPBlueToothContentVC :CBCentralManagerDelegate{
    
    /// CBCentralManagerDelegate
    //2.检查运行这个App的设备是不是支持BLE。代理方法
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        var msg = ""
        switch central.state {
        case .poweredOn:///蓝牙已打开,请扫描外设
            scanDevice()
            msg = "蓝牙已打开,请扫描外设"
        case .unauthorized://这个应用程序是无权使用蓝牙低功耗
            msg = "这个应用程序是无权使用蓝牙低功耗"
        case .poweredOff:
            GYZAlertViewTools.alertViewTools.showAlert(title: "温馨提示", message: "蓝牙目前已关闭，请打开蓝牙", cancleTitle: nil, viewController: self, buttonTitles: "确定")
            msg = "蓝牙目前已关闭"
        default:
            msg = "中央管理器没有改变状态"
        }
        GYZLog(msg)
    }
    //3.查到外设后，停止扫描，连接设备
    //广播、扫描的响应数据保存在advertisementData 中，可以通过CBAdvertisementData 来访问它。
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        GYZLog(peripheral.name)
        let name: String = advertisementData["kCBAdvDataLocalName"] as! String
        GYZLog(peripheral.name)
        if !name.isEmpty {
            if name.hasPrefix("HoopeuRobot"){//HoopeuRobot
                self.desLab1.text = "选择设备"
                self.hud?.hide(animated: true)
                
                if(!self.deviceList.contains(peripheral)){
                    self.deviceList.append(peripheral)
                    self.deviceNameList.append(name)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //连接外设失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.hud?.hide(animated: true)
        MBProgressHUD.showAutoDismissHUD(message: "蓝牙连接失败，请重新连接")
        GYZLog(error)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.hud?.hide(animated: true)
        MBProgressHUD.showAutoDismissHUD(message: "蓝牙断开连接，请重新连接")
//        createHUD(message: "重新连接中...")
//        self.manager!.connect(self.currentPeripheral!, options: nil)
    }
    //4.连接外设成功，开始发现服务
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        MBProgressHUD.showAutoDismissHUD(message: "蓝牙连接成功")
        //停止扫描外设
        self.manager!.stopScan()
        self.hud?.hide(animated: true)
        goWifiVC()
    }
}
