//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

example(of: "ignoreElements") {
  let strikes = PublishSubject<String>()
  let disposeBag = DisposeBag()
  
  strikes
    .ignoreElements()
    .subscribe { _ in
      print("You're out!")
    }
    .disposed(by: disposeBag)
  
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
  
  strikes.onCompleted()
}

example(of: "elementAt") {
  let strikes = PublishSubject<String>()
  let disposeBag = DisposeBag()
  
  strikes
    .elementAt(2)
    .subscribe(onNext: { _ in
      print("You're out!")
    })
    .disposed(by: disposeBag)
  
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
}

example(of: "filter") {
  let disposeBag = DisposeBag()
  
  Observable.of(1, 2, 3, 4, 5, 6)
    .filter { integer in
      integer % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "skip") {
  let disposeBag = DisposeBag()
  
  Observable.of("A", "B", "C", "D", "E", "F")
    .skip(3)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "skipWhile") {
  let disposeBag = DisposeBag()
  
  Observable.of(2, 2, 3, 4, 4)
    .skipWhile { integer in
      integer % 2 == 0
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "skipUntil") {
  let disposeBag = DisposeBag()
  
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()
  
  subject
    .skipUntil(trigger)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
  
  subject.onNext("A")
  subject.onNext("B")
  
  trigger.onNext("X")
  
  subject.onNext("C")
}

example(of: "take") {
  let disposeBag = DisposeBag()
  
  Observable.of(1, 2, 3, 4, 5, 6)
    .take(3)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "takeWhileWithIndex") {
  let disposeBag = DisposeBag()
  
  Observable.of(2, 2, 4, 4, 6, 6)
    .takeWhileWithIndex { integer, index in
      integer % 2 == 0 && index < 3
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "takeUntil") {
  let disposeBag = DisposeBag()
  
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()
  
  subject
    .takeUntil(trigger)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
  
  subject.onNext("1")
  subject.onNext("2")
  
  trigger.onNext("X")
  
  subject.onNext("3")
}

example(of: "distinctUntilChanged") {
  let disposeBag = DisposeBag()
  
  Observable.of("A", "A", "B", "B", "A")
    .distinctUntilChanged()
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
  let disposeBag = DisposeBag()
  
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut
  
  Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
    .distinctUntilChanged { a, b in
      guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
        let bWords = formatter.string(from: b)?.components(separatedBy: " ")
        else { return false }
      
      var containsMatch = false
      for aWord in aWords {
        for bWord in bWords {
          if aWord == bWord {
            containsMatch = true
            break
          }
        }
      }
      return containsMatch
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
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
