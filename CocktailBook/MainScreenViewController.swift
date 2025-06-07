import UIKit

class MainScreenViewController: UIViewController {
    
    private let dataManager: CocktailDataManager
    private var currentFilter: FilterType = .all
    private var cocktails: [Cocktail] = []
    private var isLoading = false
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let filterSegmentedControl: UISegmentedControl = {
        let items = FilterType.allCases.map { $0.title }
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Failed to load cocktails"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    init() {
        let cocktailsAPI: CocktailsAPI = FakeCocktailsAPI()
        self.dataManager = CocktailDataManager(cocktailsAPI: cocktailsAPI)
        super.init(nibName: nil, bundle: nil)
        
        self.dataManager.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(filterSegmentedControl)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)
        
        // Error view setup
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CocktailTableViewCell.self, forCellReuseIdentifier: CocktailTableViewCell.identifier)
        
        // Setup segmented control
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        
        // Setup retry button
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Filter segmented control
            filterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Error view
            errorView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 16),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Error label
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -30),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: errorView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: errorView.trailingAnchor, constant: -16),
            
            // Retry button
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 100),
            retryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        updateNavigationTitle()
    }
    
    private func updateNavigationTitle() {
        title = currentFilter.title
    }
    
    private func loadData() {
        showLoading(true)
        dataManager.loadData()
    }
    
    private func showLoading(_ show: Bool) {
        isLoading = show
        if show {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            errorView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    private func showError() {
        tableView.isHidden = true
        errorView.isHidden = false
    }
    
    private func showCocktails() {
        tableView.isHidden = false
        errorView.isHidden = true
    }
    
    private func updateCocktailsList() {
        cocktails = dataManager.filteredCocktails(for: currentFilter)
        tableView.reloadData()
    }
    
    @objc private func filterChanged() {
        let selectedIndex = filterSegmentedControl.selectedSegmentIndex
        currentFilter = FilterType.allCases[selectedIndex]
        updateNavigationTitle()
        updateCocktailsList()
    }
    
    @objc private func retryButtonTapped() {
        loadData()
    }
}

// MARK: - CocktailDataManagerDelegate
extension MainScreenViewController: CocktailDataManagerDelegate {
    func dataManagerDidUpdateCocktails(_ manager: CocktailDataManager) {
        showLoading(false)
        showCocktails()
        updateCocktailsList()
    }
    
    func dataManagerDidFailToLoadCocktails(_ manager: CocktailDataManager, error: Error) {
        showLoading(false)
        showError()
    }
}

// MARK: - UITableViewDataSource
extension MainScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cocktails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CocktailTableViewCell.identifier, for: indexPath) as! CocktailTableViewCell
        let cocktail = cocktails[indexPath.row]
        cell.configure(with: cocktail)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cocktail = cocktails[indexPath.row]
        let detailViewController = CocktailDetailViewController(cocktail: cocktail)
        detailViewController.delegate = self
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - CocktailDetailViewControllerDelegate
extension MainScreenViewController: CocktailDetailViewControllerDelegate {
    func cocktailDetailViewController(_ controller: CocktailDetailViewController, didToggleFavorite cocktail: Cocktail) {
        dataManager.toggleFavorite(for: cocktail.id)
    }
}
