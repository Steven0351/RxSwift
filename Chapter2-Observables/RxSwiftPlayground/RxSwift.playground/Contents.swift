//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

example(of: "just, of, from") {
  let one = 1
  let two = 2
  let three = 3
  
  // just takes a single paramter and returns an observable of type T
  let observable: Observable<Int> = Observable<Int>.just(one)
  // of takes a variadic parameter and returns an observable of type T
  let observable2 = Observable.of(one, two, three)
  let observable3 = Observable.of([one, two, three])
  // from takes an array of type T and returns an observable of type T
  let observable4 = Observable.from([one, two, three])
  
}

example(of: "subscribe") {
  let one = 1
  let two = 2
  let three = 3
  
  let observable = Observable.of(one, two, three)
  
  observable.subscribe(onNext: { element in
    print(element)
  })
  
}

example(of: "empty") {
  let observable = Observable<Void>.empty()
  
  observable.subscribe(onNext: { element in
    print(element)
  }, onCompleted: {
    print("completed")
  })
}

example(of: "never") {
  let observable = Observable<Any>.never()
  let disposeBag = DisposeBag()
  
  observable
    .do(onSubscribe: {
      print("Subscribed!")
    })
    .subscribe(onNext: { element in
      print(element)
    }, onCompleted: {
      print("completed")
    })
    .disposed(by: disposeBag)

}

example(of: "never") {
  let observable = Observable<Any>.never()
  let disposeBag = DisposeBag()
  
  observable
    .debug("Debugging", trimOutput: false)
    .subscribe(onNext: { element in
      print(element)
    }, onCompleted: {
      print("completed")
    })
    .disposed(by: disposeBag)
  
}


example(of: "range") {
  let observable = Observable<Int>.range(start: 1, count: 10)
  
  observable
    .subscribe(onNext: { i in
      
      let n = Double(i)
      let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
      print(fibonacci)
      
    })
  
}

example(of: "dispose") {
  let observable = Observable.of("A", "B", "C")
  
  let subscription = observable.subscribe { event in
    print(event)
  }
  
  subscription.dispose()
}

example(of: "DisposeBag") {
  let disposeBag = DisposeBag()
  
  Observable.of("A", "B", "C")
    .subscribe {
      print($0)
    }
    .disposed(by: disposeBag)
}

example(of: "create") {
  enum MyError: Error {
    case anError
  }
  
  let disposeBag = DisposeBag()
  
  Observable<String>.create { observer in
    observer.onNext("1")
//    observer.onError(MyError.anError)
    observer.onCompleted()
    observer.onNext("?")
    return Disposables.create()
  }
  .subscribe(
    onNext: { print($0) },
    onError: { print($0) },
    onCompleted: { print("Completed") },
    onDisposed: { print("Disposed") }
  )
  .disposed(by: disposeBag)
}

example(of: "deferred") {
  let disposeBag = DisposeBag()
  
  var flip = false
  
  let factory: Observable<Int> = Observable.deferred {
    flip = !flip
    
    if flip {
      return Observable.of(1, 2, 3)
    } else {
      return Observable.of(4, 5, 6)
    }
  }
  
  for _ in 0...3 {
    factory.subscribe(onNext: {
      print($0, terminator: "")
    })
    .disposed(by: disposeBag)
    
    print()
  }
}

/*:
 Copyright (c) 2014-2016 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
