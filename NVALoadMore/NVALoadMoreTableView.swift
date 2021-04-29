//
//  NVALoadMoreTableView.swift
//  NVALoadMore
//
//  Created by ngo.viet.anh on 18/04/2021.
//

import Foundation
import RxSwift
import RxCocoa

open class NVALoadMoreTableView: UITableView {
    
    // MARK: - Reload
    private let _refreshControl = UIRefreshControl()
    
    open var refreshTrigger: Driver<Void> {
        return _refreshControl.rx.controlEvent(.valueChanged).asDriver()
    }
    
    open var isRefreshing: Binder<Bool> {
        return Binder(self) { tableView, loading in
            if loading {
                tableView._refreshControl.beginRefreshing()
            } else {
                if tableView._refreshControl.isRefreshing {
                    tableView._refreshControl.endRefreshing()
                }
            }
        }
    }
    
    // MARK: - Load More
    private lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 60))
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        return view
    }()
    
    open var loadMoreTrigger: Driver<Void> {
        rx.reachedBottom(offset: 0.0).asDriver()
    }
    
    open var isLoadingMore: Binder<Bool> {
        return Binder(self) { tableView, loading in
            tableView.tableFooterView = loading ? tableView.footerView : nil
        }
    }
    
    // MARK: - Life cycle
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configViews()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configViews()
    }
    
    // MARK: - Function
    private func configViews() {
        addRefreshControl()
    }
    
    open func addRefreshControl() {
        if #available(iOS 10.0, *) {
            self.refreshControl = _refreshControl
        } else {
            guard !self.subviews.contains(_refreshControl) else { return }
            self.addSubview(_refreshControl)
        }
    }

    open func removeRefreshControl() {
        if #available(iOS 10.0, *) {
            self.refreshControl = nil
        } else {
            _refreshControl.removeFromSuperview()
        }
    }
}
