//
//  DownloadView.swift
//  OurPlanet
//
//  Created by Steven Sherry on 9/15/17.
//  Copyright © 2017 Florent Pillet. All rights reserved.
//

import Foundation
import UIKit

class DownloadView: UIStackView {
  
  let label = UILabel()
  let progress = UIProgressView()
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    translatesAutoresizingMaskIntoConstraints = false
    
    // MARK: - Set StackView Properties
    
    axis = .horizontal
    spacing = 0
    distribution = .fillEqually
    
    // MARK: - Programmatic View Layout
    
    if let superview = superview {
      backgroundColor = .white
      
      // MARK: Programmatic AutoLayout
      
      bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
      leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
      rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
      heightAnchor.constraint(equalToConstant: 38).isActive = true
      
      progress.translatesAutoresizingMaskIntoConstraints = false
      
      let progressWrap = UIView()
      progressWrap.translatesAutoresizingMaskIntoConstraints = false
      progressWrap.backgroundColor = .lightGray
      progressWrap.addSubview(progress)
      
      progress.leftAnchor.constraint(equalTo: progressWrap.leftAnchor).isActive = true
      progress.rightAnchor.constraint(equalTo: progressWrap.rightAnchor).isActive = true
      progress.heightAnchor.constraint(equalToConstant: 4).isActive = true
      progress.centerYAnchor.constraint(equalTo: progressWrap.centerYAnchor).isActive = true
      
      label.text = "Downloads"
      label.translatesAutoresizingMaskIntoConstraints = false
      label.backgroundColor = .lightGray
      label.textAlignment = .center
      
      addArrangedSubview(label)
      addArrangedSubview(progressWrap)
    }
  }
}
