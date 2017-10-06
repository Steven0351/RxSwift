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

import Foundation
import RxSwift
import RxDataSources
import Action

typealias TaskSection = AnimatableSectionModel<String, TaskItem>

struct TasksViewModel {
  
  let sceneCoordinator: SceneCoordinatorType
  let taskService: TaskServiceType

  init(taskService: TaskServiceType, coordinator: SceneCoordinatorType) {
    self.taskService = taskService
    self.sceneCoordinator = coordinator
  }
  
  var sectionedItems: Observable<[TaskSection]> {
    return self.taskService.tasks()
      .map { results in
        let dueTasks = results
          .filter("checked == nil")
          .sorted(byKeyPath: "added", ascending: false)
        
        let doneTasks = results
          .filter("checked != nil")
          .sorted(byKeyPath: "checked", ascending: false)
        
        return [
          TaskSection(model: "Due Tasks", items: dueTasks.toArray()),
          TaskSection(model: "Done Tasks", items: doneTasks.toArray())
        ]
      }
  }
  
  
//  My solution - Challenge 2
//  var statistics: Observable<TaskStatistics> {
//    return self.taskService.tasks()
//      .map { results in
//        let dueTasks = results
//          .filter("checked == nil")
//          .toArray()
//          .count
//        let doneTasks = results
//          .filter("checked != nil")
//          .toArray()
//          .count
//        
//        return TaskStatistics(todo: dueTasks, done: doneTasks)
//      }
//    return self.taskService.calculateStatistics()
//  }
  
  // Book solution - Challenge 2
  lazy var statistics: Observable<TaskStatistics> = self.taskService.statistics()

  // The use of "this" as the local variable is using the input of self in the lazy initializer. This is because a
  // closure cannot implicitly capture a mutating self parameter, as well as the inability to create weak or unowned
  // references to structs
  lazy var editAction: Action<TaskItem, Void> = { this in
    return Action { task in
      let editViewModel = EditTaskViewModel(task: task,
                                            coordinator: this.sceneCoordinator,
                                            updateAction: this.onUpdateTitle(task: task))
      return this.sceneCoordinator.transition(to: Scene.editTask(editViewModel), type: .modal)
    }
  }(self)
  
  // My solution - Challenge 1
//  lazy var deleteAction: Action<TaskItem, Void> = { this in
//    return Action { task in
//      return this.taskService.delete(task: task)
//    }
//  }(self)
  // Book Solution - Challenge 1 - pretty much the same, this is less verbose and I didn't know 
  // anything about lazy initialization before this book. I'll need to look more into it
  
  lazy var deleteAction: Action<TaskItem, Void> = { (service: TaskServiceType) in
    return Action { item in
      return service.delete(task: item)
    }
  }(self.taskService)
  
  func onToggle(task: TaskItem) -> CocoaAction {
    return CocoaAction {
      return self.taskService.toggle(task: task).map { _ in }
    }
  }

  func onDelete(task: TaskItem) -> CocoaAction {
    return CocoaAction {
      return self.taskService.delete(task: task)
    }
  }

  func onUpdateTitle(task: TaskItem) -> Action<String, Void> {
    return Action { newTitle in
      return self.taskService.update(task: task, title: newTitle).map { _ in }
    }
  }
  
  func onCreateTask() -> CocoaAction {
    /*
     Since self is a struct, the action gets its own "copy" of the struct (optimized by Swift to being just a reference)
     and there is no circular reference - no risk of leaking memory! That's why you don't see [weak self] or 
     [unowned self] here, which don't apply to value types.
    */
    return CocoaAction { _ in
      return self.taskService
        .createTask(title: "")
        .flatMap { task -> Observable<Void> in
          let editViewModel = EditTaskViewModel(task: task,
                                                coordinator: self.sceneCoordinator,
                                                updateAction: self.onUpdateTitle(task: task),
                                                cancelAction: self.onDelete(task: task))
          return self.sceneCoordinator.transition(to: Scene.editTask(editViewModel), type: .modal)
        }
    }
  }
}
