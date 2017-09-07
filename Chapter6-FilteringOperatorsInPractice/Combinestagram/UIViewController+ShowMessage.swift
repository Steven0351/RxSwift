//
//  UIViewController+ShowMessage.swift
//  Combinestagram
//
//  Created by Steven Sherry on 9/6/17.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UIViewController {

  // My solution to the challenge
  func showMessageObserver(_ title: String, description: String? = nil) -> Observable<Void> {
    return Observable.create({ [weak self] observer in
      let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {  _ in
        self?.dismiss(animated: true, completion: nil)
        observer.onCompleted()
      }))
      self?.present(alert, animated: true, completion: nil)
      return Disposables.create()
    })
  }
  
  // Book solution
  func alert(title: String, text: String?) -> Observable<Void> {
    return Observable.create({ [weak self ] observer in
      let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
      alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
        observer.onCompleted()
      }))
      self?.present(alertVC, animated: true)
      return Disposables.create {
        self?.dismiss(animated: true)
      }
    })
  }
}
