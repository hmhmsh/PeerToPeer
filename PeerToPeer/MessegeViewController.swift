//
//  MessegeViewController.swift
//  PeerToPeer
//
//  Created by 長谷川瞬哉 on 2015/07/21.
//  Copyright (c) 2015年 長谷川瞬哉. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics
import MultipeerConnectivity

class MessegeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
  
  var myTableView: UITableView!
  
  var sessionHelper: SessionHelper!
  var selectedPeerID: MCPeerID!
  
  var messegeList: NSMutableArray!
  var messege: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Status Barの高さを取得.
    let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
    
    // Viewの高さと幅を取得.
    let displayWidth: CGFloat = self.view.frame.width
    let displayHeight: CGFloat = self.view.frame.height
    
    // TableViewの生成( status barの高さ分ずらして表示 ).
    myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
    
    // Cellの登録.
    myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
    
    // DataSourceの設定.
    myTableView.dataSource = self
    
    // Delegateを設定.
    myTableView.delegate = self
    
    // Viewに追加する.
    self.view.addSubview(myTableView)
    
    messegeList = NSMutableArray()
    
    messege = UITextField()
    messege.frame = CGRectMake(0, 0, 200, 50)
    messege.center = self.view.center
    messege.delegate = self
    messege.borderStyle = UITextBorderStyle.RoundedRect
    self.view.addSubview(messege)
  }
  
  /*
  Cellが選択された際に呼び出される.
  */
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  /*
  Cellの総数を返す.
  */
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messegeList.count
  }
  
  /*
  Cellに値を設定する.
  */
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell" )
    
    cell.textLabel!.text = messegeList[indexPath.row] as? String
    
    return cell;
  }
  
  /*
  UITextFieldが編集終了する直前に呼ばれるデリゲートメソッド.
  */
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    
    return true
  }
  
  /*
  改行ボタンが押された際に呼ばれるデリゲートメソッド.
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    messegeList.addObject(textField.text)
    sessionHelper.sendMessege(textField.text, peerID: selectedPeerID)

    return true
  }
  
}

