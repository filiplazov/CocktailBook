import UIKit

protocol CocktailDetailViewControllerDelegate: AnyObject {
    func cocktailDetailViewController(_ controller: CocktailDetailViewController, didToggleFavorite cocktail: Cocktail)
}

class CocktailDetailViewController: UIViewController {
    
    weak var delegate: CocktailDetailViewControllerDelegate?
    
    private var cocktail: Cocktail
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        return stack
    }()
    
    private let cocktailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let preparationView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let preparationStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private let preparationIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let preparationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let ingredientsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingredients"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let ingredientsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    init(cocktail: Cocktail) {
        self.cocktail = cocktail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = cocktail.name
        
        // Navigation bar setup
        navigationItem.largeTitleDisplayMode = .never
        
        // Favorite button
        let favoriteButton = UIBarButtonItem(
            image: cocktail.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        favoriteButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = favoriteButton
        
        // Setup scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureContent() {
        // Cocktail image
        cocktailImageView.image = UIImage(named: cocktail.imageName)
        stackView.addArrangedSubview(cocktailImageView)
        
        cocktailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cocktailImageView.heightAnchor.constraint(equalToConstant: 200),
            cocktailImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        
        // Preparation time
        preparationView.addSubview(preparationStackView)
        preparationStackView.addArrangedSubview(preparationIconImageView)
        preparationStackView.addArrangedSubview(preparationLabel)
        
        preparationLabel.text = "\(cocktail.preparationMinutes) minutes"
        
        preparationStackView.translatesAutoresizingMaskIntoConstraints = false
        preparationIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            preparationStackView.topAnchor.constraint(equalTo: preparationView.topAnchor, constant: 12),
            preparationStackView.leadingAnchor.constraint(equalTo: preparationView.leadingAnchor, constant: 12),
            preparationStackView.trailingAnchor.constraint(equalTo: preparationView.trailingAnchor, constant: -12),
            preparationStackView.bottomAnchor.constraint(equalTo: preparationView.bottomAnchor, constant: -12),
            
            preparationIconImageView.widthAnchor.constraint(equalToConstant: 20),
            preparationIconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        stackView.addArrangedSubview(preparationView)
        preparationView.translatesAutoresizingMaskIntoConstraints = false
        
        // Description
        descriptionLabel.text = cocktail.longDescription
        stackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        
        // Ingredients header
        stackView.addArrangedSubview(ingredientsHeaderLabel)
        
        // Ingredients list
        for ingredient in cocktail.ingredients {
            let ingredientView = createIngredientView(text: ingredient)
            ingredientsStackView.addArrangedSubview(ingredientView)
        }
        
        stackView.addArrangedSubview(ingredientsStackView)
        ingredientsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ingredientsStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }
    
    private func createIngredientView(text: String) -> UIView {
        let containerView = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .top
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "circle.fill")
        iconImageView.tintColor = .systemGreen
        iconImageView.contentMode = .scaleAspectFit
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textLabel.numberOfLines = 0
        textLabel.textColor = .label
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(textLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 8),
            iconImageView.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        return containerView
    }
    
    @objc private func favoriteButtonTapped() {
        cocktail.isFavorite.toggle()
        
        // Update navigation bar button
        let favoriteButton = UIBarButtonItem(
            image: cocktail.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        favoriteButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = favoriteButton
        
        delegate?.cocktailDetailViewController(self, didToggleFavorite: cocktail)
    }
} 