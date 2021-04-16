//
//  MediaListVC.swift
//  MediaListing
//
//  Created by Rahul Mayani on 25/03/21.
//

import UIKit
import RxSwift
import RxCocoa

class MediaListVC: BaseVC {
    // MARK: - IBOutlet -
    @IBOutlet weak var listTableView: UITableView!
    
    // MARK: - Variable -
    // interaction between view and model by listing view model
    public let listingVM = ListingVM()
    
    private var dataList: [MediaModel] = []
    
    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // pull To Refresh
        listingVM.refreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        listTableView.addSubview(listingVM.refreshControl)
        
        // Get data from Server
        listingVM.getDataFromServer(true)
        
        // Get data array by rxswift
        listingVM.dataArray
        .subscribe { [weak self] (mediaList) in
            guard let self = self else { return }
            self.dataList = self.listingVM.dataArray.value
            self.listTableView.reloadData()
        }.disposed(by: rxbag)
    }
    
    // MARK: - Others -
    @objc
    private func pullToRefresh() {
        listingVM.refreshControl.beginRefreshing()
        listingVM.getDataFromServer(false)
    }
}

// MARK: - UITableView -
extension MediaListVC: UITableViewDataSource ,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let media = dataList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MediaListCell.self), for: indexPath) as! MediaListCell
        cell.data = media
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let media = dataList[indexPath.row]
        let mediaDetailsController: MediaDetailsVC = self.storyboard!.loadViewController()
        mediaDetailsController.data = media
        mediaDetailsController.title = "\(media.mediaId ?? 0)"
        self.navigationController?.pushViewController(mediaDetailsController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
        if editingStyle == .delete {
            dataList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
    }
}
