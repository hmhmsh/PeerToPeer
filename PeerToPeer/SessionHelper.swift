//
//  SessionHelper.swift
//  PeerToPeer
//
//  Created by 長谷川瞬哉 on 2015/07/19.
//  Copyright (c) 2015年 長谷川瞬哉. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics
import MultipeerConnectivity

//static NSString * const ServiceType = @"cm-p2ptest";

protocol SessionHelperDelegate
{
  func sessionHelperDidChangeConnectedPeers(sessionHelper: SessionHelper)
  func sessionHelperDidRecieveImage(image: UIImage, peerID:MCPeerID)
  func sessionHelperDidRecieveMessege(messege: NSString, peerID:MCPeerID)
}

class SessionHelper: NSObject, MCSessionDelegate {
  
  internal var session:  MCSession!
  internal var serviceType: NSString!{
    get {
      return "cm-p2ptest"
    }
  }
  internal var connectedPeersCount: UInt!{
    get {
      return UInt(connectedPeerIDs.count)
    }
  }
  internal var delegate: SessionHelperDelegate!

  var advertiserAssistant: MCAdvertiserAssistant!
  var connectedPeerIDs:NSMutableArray!
  
//  func getServiceType() -> NSString
//  {
//    return serviceType;
//  }
//  

  func initWithDisplayName(displayName: NSString)
  {
    self.connectedPeerIDs = NSMutableArray()
  
    var peerID : MCPeerID = MCPeerID(displayName: displayName as String)
    session = MCSession(peer: peerID)
    session.delegate = self;
  
    advertiserAssistant = MCAdvertiserAssistant(serviceType: serviceType! as String, discoveryInfo: [NSObject : AnyObject]() , session: session!)
    advertiserAssistant.start()
    
  }
  
// MCSessionDelegate
  // Remote peer changed state
  func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
    var needToNotify:ObjCBool = false
    
    if (state == MCSessionState.Connected) {
      if (!connectedPeerIDs.containsObject(peerID)) {
        connectedPeerIDs.addObject(peerID)
        needToNotify = true
      }
    } else {
      if (connectedPeerIDs.containsObject(peerID)) {
        connectedPeerIDs.removeObject(peerID)
        needToNotify = true
      }
    }
    
    if (needToNotify) {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.delegate.sessionHelperDidChangeConnectedPeers(self)
      })
    }
  }
  
  // Received data from remote peer
  func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    var messege = NSString(data: data, encoding: NSUTF8StringEncoding)
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.delegate.sessionHelperDidRecieveMessege(messege!, peerID: peerID)
    })
    
//    var image = UIImage(data: data)
//    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//      self.delegate.sessionHelperDidRecieveImage(image!, peerID: peerID)
//    })
  }
  
  // Received a byte stream from remote peer
  func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    
  }
  
  // Start receiving a resource from remote peer
  func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
    
  }
  
  // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
  func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
    
  }
  
//  #pragma mark - Public methods
  internal func connectedPeerIDAtIndex(index: UInt) -> MCPeerID? {
    if (index >= UInt(connectedPeerIDs.count)) {
      return nil;
    }
  
    return connectedPeerIDs[Int(index)] as? MCPeerID;
  }
  
  internal func sendImage(image: UIImage, peerID: MCPeerID) {
    var data: NSData = UIImageJPEGRepresentation(image, 0.9);
  
    var error: NSError?
    session.sendData(data, toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable, error: &error)
    
    if ((error) != nil) {
      println("Failed \(error)")
    }
  }

  internal func sendMessege(messege: NSString, peerID: MCPeerID) {
    var data: NSData = messege.dataUsingEncoding(NSUTF8StringEncoding)!;
    
    var error: NSError?
    session.sendData(data, toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable, error: &error)
    
    if ((error) != nil) {
      println("Failed \(error)")
    }
  }

}

