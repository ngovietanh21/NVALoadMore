//
//  ViewController.swift
//  NVALoadMore
//
//  Created by ngo.viet.anh on 18/04/2021.
//

import UIKit
import RxSwift
import RxCocoa

@propertyWrapper
public struct Property<Value> {
    
    private var subject: BehaviorRelay<Value>
   
    public var wrappedValue: Value {
        get {
            return subject.value
        }
        set {
            subject.accept(newValue)
        }
    }
    
    public var projectedValue: BehaviorRelay<Value> {
        return self.subject
    }
    
    public init(wrappedValue: Value) {
        subject = BehaviorRelay(value: wrappedValue)
    }
}

struct ViewModel {
    
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
        let loadMoreTrigger: Driver<Void>
    }
    
    struct Output {
        @Property var cells = [Int]()
        @Property var isReloading = false
        @Property var isLoadingMore = false
    }
    
    func transform(input: Input, bag: DisposeBag) -> Output {
        let output = Output()
        
        input.loadTrigger
            .map { [1,2,3,4,5,6,7,8,9,10,11,12] }
            .drive(output.$cells)
            .disposed(by: bag)
        
        input.reloadTrigger.map { true }.drive(output.$isReloading).disposed(by: bag)
        
        input.reloadTrigger
            .delay(.seconds(3))
            .map { [1,2,3,4,5,6,7,8,9,10,11,12] }
            .drive(onNext: {
                output.$isReloading.accept(false)
                output.$cells.accept($0)
            })
            .disposed(by: bag)
        
        input.loadMoreTrigger.map { true }.drive(output.$isLoadingMore).disposed(by: bag)
        
        input.loadMoreTrigger
            .delay(.seconds(3))
            .withLatestFrom(output.$cells.asDriver())
            .map { list -> [Int] in
                output.$isLoadingMore.accept(false)
                guard let last = list.last else { return [] }
                return list + [last + 1, last + 2, last + 3, last + 4]
            }
            .drive(output.$cells)
            .disposed(by: bag)
        
        return output
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: NVALoadMoreTableView!
    
    let bag = DisposeBag()
    
    var viewModel: ViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ViewModel()
        
        tableView.rowHeight = 120
        
        bindViewModel()
    }
    
    func bindViewModel() {
        let input = ViewModel.Input(
            loadTrigger: .just(()),
            reloadTrigger: tableView.refreshTrigger,
            loadMoreTrigger: tableView.loadMoreTrigger
        )
        
        let output = viewModel.transform(input: input, bag: bag)
        
        output.$cells.asDriver()
            .drive(tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cells")!
                cell.textLabel?.text = "\(element) @ row \(row)"
                return cell
            }
            .disposed(by: bag)
        
        output.$isReloading.asDriver()
            .drive(tableView.isRefreshing)
            .disposed(by: bag)
        
        output.$isLoadingMore.asDriver()
            .drive(tableView.isLoadingMore)
            .disposed(by: bag)
    }
}

