/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxDataSources
import Action
import NSObject_Rx

class TasksViewController: UIViewController, BindableType {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var statisticsLabel: UILabel!
  @IBOutlet var newTaskButton: UIBarButtonItem!
  
  let dataSource = RxTableViewSectionedAnimatedDataSource<TaskSection>()
  
  var viewModel: TasksViewModel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    
    
    configureDataSource()
    
    viewModel.sectionedItems
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: self.rx_disposeBag)
    
    
    
    // This will only allow swiping tableView cells if the tableView has a subscription to .rx.itemDeleted
    setEditing(true, animated: false)
  }
  
  func bindViewModel() {
    newTaskButton.rx.action = viewModel.onCreateTask()
    
    tableView.rx.itemSelected
      .map { [unowned self] indexPath in
        try! self.dataSource.model(at: indexPath) as! TaskItem
      }
      .subscribe(viewModel.editAction.inputs)
      .disposed(by: rx_disposeBag)
    
    // My solution Challenge 1
    
    tableView.rx.itemDeleted
      .map { [unowned self] indexPath in
        try! self.dataSource.model(at: indexPath) as! TaskItem
      }
      .subscribe(viewModel.deleteAction.inputs)
      .disposed(by: rx_disposeBag)
    
//    My solution Challenge 2
    viewModel.statistics
      .map {
        return "To Do: \($0.todo), Completed: \($0.done)"
      }
      .bind(to: statisticsLabel.rx.text)
      .disposed(by: rx_disposeBag)
    
    // Book Solution Challenge 2 - The whole reason I ran through this exercise of checking their code
    // was because when I tested the code of MY implementation, it wouldn't add any information to the 
    // statistics label...neither does theirs. So for THAT reason, I actually prefer my implementation
    // as I feel like it's more expressive on what it's doing at a casual glance.
//    viewModel.statistics
//      .subscribe(onNext: { [weak self] stats in
//        let total = stats.todo + stats.done
//        self?.statisticsLabel.text = "\(total) tasks, \(stats.todo) due."
//      })
//      .disposed(by: rx_disposeBag)
    
  }
  
  fileprivate func configureDataSource() {
    dataSource.titleForHeaderInSection = { dataSource, index in
      dataSource.sectionModels[index].model
    }
    
    dataSource.canEditRowAtIndexPath = { _, _ in
      return true
    }
    
    
    dataSource.configureCell = { [weak self] dataSource, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: "TaskItemCell", for: indexPath) as! TaskItemTableViewCell
      if let strongSelf = self {
        cell.configure(with: item, action: strongSelf.viewModel.onToggle(task: item))
      }
      return cell
    }
  }
  
}
