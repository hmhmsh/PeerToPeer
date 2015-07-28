//
//  TargetListViewController.swift
//  PeerToPeer
//
//  Created by 長谷川瞬哉 on 2015/07/19.
//  Copyright (c) 2015年 長谷川瞬哉. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics
import MultipeerConnectivity

class TargetListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SessionHelperDelegate, MCBrowserViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  
  var myTableView: UITableView!
  
  var sessionHelper: SessionHelper!
  var selectedPeerID: MCPeerID!
  var displayName: NSString!
  
  var messegeView: MessegeViewController!

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
    
    var browse: UIBarButtonItem = UIBarButtonItem(title: "Browse", style: UIBarButtonItemStyle.Plain, target: self, action: "browseButtonDidTouch:")
    self.navigationItem.rightBarButtonItem = browse
  }
  
  /*
  Cellが選択された際に呼び出される.
  */
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedPeerID = sessionHelper.connectedPeerIDAtIndex(UInt(indexPath.row))
    
    if ((selectedPeerID) != nil) {
      messegeView = MessegeViewController()
      messegeView.title = selectedPeerID.displayName
      messegeView.sessionHelper = sessionHelper
      messegeView.selectedPeerID = selectedPeerID
      
      // アニメーションを設定する.
      messegeView.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
      
      println(self.navigationController)
      // Viewの移動する.
      self.navigationController?.pushViewController(messegeView, animated: true)

//      var imagePickerController: UIImagePickerController = UIImagePickerController()
//      imagePickerController.delegate = self;
//      imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
//      self.presentViewController(imagePickerController, animated: true, completion: nil)
    }

  }
  
  /*
  Cellの総数を返す.
  */
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Int(sessionHelper.connectedPeersCount)
  }
  
  /*
  Cellに値を設定する.
  */
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier:"MyCell" )
    
    var peerID: MCPeerID = sessionHelper.connectedPeerIDAtIndex(UInt(indexPath.row))!
    cell.textLabel!.text = peerID.displayName
    
    return cell;

  }

  //  #pragma mark - SessionHelperDelegate methods
  
  func sessionHelperDidChangeConnectedPeers(sessionHelper: SessionHelper) {
    myTableView.reloadData()
  }
  
  func sessionHelperDidRecieveImage(image: UIImage, peerID:MCPeerID) {
    UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
  }
  
  func sessionHelperDidRecieveMessege(messege: NSString, peerID:MCPeerID) {
    messegeView.messegeList.addObject(messege)
    messegeView.myTableView.reloadData()
  }

  
//  #pragma mark - UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    var image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    self.sessionHelper.sendImage(image, peerID: selectedPeerID)
    self.selectedPeerID = nil;
    
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //  #pragma mark - MCBrowserViewControllerDelegate methods
  
  // Notifies delegate that a peer was found; discoveryInfo can be used to determine whether the peer should be presented to the user, and the delegate should return a YES if the peer should be presented; this method is optional, if not implemented every nearby peer will be presented to the user.
  func browserViewController(browserViewController: MCBrowserViewController!, shouldPresentNearbyPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) -> Bool {
    // ここで、表示するかどうかの判断
    // ここでマッチングをする予定
    return true;
  }

  // Notifies the delegate, when the user taps the done button
  func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!){
    browserViewController.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // Notifies delegate that the user taps the cancel button.
  func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!){
    browserViewController.dismissViewControllerAnimated(true, completion: nil)
  }
  
//  #pragma mark - Handler methods

  func browseButtonDidTouch(sender: AnyObject)
  {    
    var view: MCBrowserViewController = MCBrowserViewController(serviceType: String(sessionHelper.serviceType) , session: sessionHelper.session)
    view.delegate = self
    self.presentViewController(view, animated: true, completion: nil)

  }
  
  func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
    if error != nil {
      //プライバシー設定不許可など書き込み失敗時は -3310 (ALAssetsLibraryDataUnavailableError)
      println(error.code)
    }
    else {
      var alertView: UIAlertView = UIAlertView(title: nil, message: "受信した画像をカメラロールに保存しました。", delegate: self, cancelButtonTitle: "OK")
      alertView.show()
    }
  }
  
  func createSessionWithDisplayName(displayName: NSString) {
    self.sessionHelper = SessionHelper()
    sessionHelper.initWithDisplayName(displayName)
    self.sessionHelper.delegate = self;
  }

}

