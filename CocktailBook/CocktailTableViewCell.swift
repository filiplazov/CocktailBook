import UIKit

class CocktailTableViewCell: UITableViewCell {
    
    static let identifier = "CocktailTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemRed
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(stackView)
        contentView.addSubview(favoriteImageView)
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            stackView.trailingAnchor.constraint(equalTo: favoriteImageView.leadingAnchor, constant: -8),
            
            favoriteImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 24),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with cocktail: Cocktail) {
        nameLabel.text = cocktail.name
        descriptionLabel.text = cocktail.shortDescription
        
        if cocktail.isFavorite {
            nameLabel.textColor = .systemRed
            favoriteImageView.image = UIImage(systemName: "heart.fill")
            favoriteImageView.isHidden = false
        } else {
            nameLabel.textColor = .label
            favoriteImageView.isHidden = true
        }
    }
} 