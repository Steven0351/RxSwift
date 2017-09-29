/*
 * Copyright (c) 2014-2016 Razeware LLC
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
import SwiftyJSON

fileprivate var internalCache = [String: Data]()

public enum RxURLSessionError: Error {
  case unknown
  case invalidResponse(response: URLResponse)
  case requestFailed(response: HTTPURLResponse, data: Data?)
  case deserializationFailed
}

extension Reactive where Base: URLSession {
  
  func response(request: URLRequest) -> Observable<(HTTPURLResponse, Data)> {
    return Observable.create { observer in
      let task = self.base.dataTask(with: request) { (data, response, error) in
        guard let response = response, let data = data else {
          observer.onError(error ?? RxURLSessionError.unknown)
          return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
          observer.onError(RxURLSessionError.invalidResponse(response: response))
          return
        }
        
        observer.onNext((httpResponse, data))
        observer.onCompleted()
      }
      task.resume()
      return Disposables.create(with: task.cancel)
    }
  }
  
  func data(request: URLRequest) -> Observable<Data> {
    
    if let url = request.url?.absoluteString, let data = internalCache[url] {
      return Observable.just(data)
    }
    
    return response(request: request).cache().map { (response, data) -> Data in
      if 200 ..< 300 ~= response.statusCode {
        return data
      } else {
        throw RxURLSessionError.requestFailed(response: response, data: data)
      }
    }
  }
  
  func string(request: URLRequest) -> Observable<String> {
    return data(request: request).map { data in
      return String(data: data, encoding: .utf8) ?? ""
    }
  }
  
  func json(request: URLRequest) -> Observable<JSON> {
    return data(request: request).map { data in
      return JSON(data: data)
    }
  }
  
  func image(request: URLRequest) -> Observable<UIImage> {
    return data(request: request).map { data in
      return UIImage(data: data) ?? UIImage()
    }
  }
}

extension ObservableType where E == (HTTPURLResponse, Data) {
  func cache() -> Observable<E> {
    return self.do(onNext: { (response, data) in
      if let url = response.url?.absoluteString, 200 ..< 300 ~= response.statusCode {
        internalCache[url] = data
      }
    })
  }
}


