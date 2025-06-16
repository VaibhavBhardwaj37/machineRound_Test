//
//  ViewController.swift
//  MachineRound_Swift
//
//  Created by Sanskar IOS Dev on 16/06/25.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchController: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortButton: UIButton!
    
    private let viewModel = SportsViewModel()
    private var filteredSports: [SportsAPI] = []
    private var currentSort: SortOption = .nameAscending
    private var isSearching: Bool {
        return !(searchController.text?.isEmpty ?? true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sports List"
        view.backgroundColor = .white
        
        setupSearchBar()
        setupTableView()
        setupSortButton()
        fetchData()
    }
    
    private func setupSortButton() {
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        sortButton.addTarget(self, action: #selector(showSortOptions), for: .touchUpInside)
    }
    
    private func setupSearchBar() {
        searchController.delegate = self
        searchController.placeholder = "Search Sports"
        searchController.searchBarStyle = .minimal
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    private func fetchData() {
        viewModel.fetchSportsData { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.filteredSports = self?.viewModel.sports ?? []
                    self?.sortFilteredSports()
                    self?.tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "Error", message: self?.viewModel.errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    private func showSportDetail(sport: SportsAPI) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailScreenSportVC") as? DetailScreenSportVC {
            detailVC.sport = sport
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    // MARK: - Sorting
    
    @objc private func showSortOptions() {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "ID (Ascending)", style: .default) { [weak self] _ in
            self?.currentSort = .idAscending
            self?.sortFilteredSports()
            self?.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "ID (Descending)", style: .default) { [weak self] _ in
            self?.currentSort = .idDescending
            self?.sortFilteredSports()
            self?.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Name (A-Z)", style: .default) { [weak self] _ in
            self?.currentSort = .nameAscending
            self?.sortFilteredSports()
            self?.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Name (Z-A)", style: .default) { [weak self] _ in
            self?.currentSort = .nameDescending
            self?.sortFilteredSports()
            self?.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sortButton
            popoverController.sourceRect = sortButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private enum SortOption {
        case idAscending
        case idDescending
        case nameAscending
        case nameDescending
    }
    
    private func sortFilteredSports() {
        switch currentSort {
        case .idAscending:
            filteredSports.sort { ($0.id ?? 0) < ($1.id ?? 0) }
        case .idDescending:
            filteredSports.sort { ($0.id ?? 0) > ($1.id ?? 0) }
        case .nameAscending:
            filteredSports.sort { ($0.sport_name ?? "") < ($1.sport_name ?? "") }
        case .nameDescending:
            filteredSports.sort { ($0.sport_name ?? "") > ($1.sport_name ?? "") }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterSports(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterSports(with: "")
    }
    

    private func filterSports(with searchText: String) {
        if searchText.isEmpty {
            filteredSports = viewModel.sports
        } else {
            filteredSports = viewModel.sports.filter { sport in
                return (sport.sport_name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                       (sport.venue_name?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        sortFilteredSports()
        tableView.reloadData()
    }

    // MARK: - UITableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSports.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sport = filteredSports[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = sport.sport_name ?? "Unnamed"
        content.secondaryText = "Venue: \(sport.venue_name ?? "N/A")"
        cell.contentConfiguration = content
        
        return cell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let sports = isSearching ? filteredSports : viewModel.sports
//        let selectedSport = sports[indexPath.row]
//        showSportDetail(sport: selectedSport)
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSport = filteredSports[indexPath.row]
        showSportDetail(sport: selectedSport)
    }

    // MARK: - Swipe to Delete
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sport = filteredSports[indexPath.row]
            if let actualIndex = viewModel.sports.firstIndex(where: { $0.id == sport.id }) {
                viewModel.deleteSport(byId: sport.id) { [weak self] success in
                    DispatchQueue.main.async {
                        if success {
                            self?.viewModel.sports.remove(at: actualIndex)
                            self?.filterSports(with: self?.searchController.text ?? "")
                        } else {
                            let errorAlert = UIAlertController(
                                title: "Error",
                                message: "Failed to delete the sport. Please try again.",
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self?.present(errorAlert, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.tableView(tableView, commit: .delete, forRowAt: indexPath)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
