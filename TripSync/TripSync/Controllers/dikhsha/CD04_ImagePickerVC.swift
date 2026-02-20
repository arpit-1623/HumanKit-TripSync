import UIKit

// MARK: - Unsplash API Models
struct UnsplashSearchResponse: Codable {
    let results: [UnsplashPhoto]
    let total: Int
    let total_pages: Int
}

struct UnsplashPhoto: Codable {
    let id: String
    let urls: UnsplashPhotoURLs
    let user: UnsplashUser
}

struct UnsplashPhotoURLs: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashUser: Codable {
    let name: String
}

// MARK: - Delegate Protocol
protocol ImagePickerDelegate: AnyObject {
    func didSelectImage(_ image: UIImage, photoData: UnsplashPhoto)
}

class CD04_ImagePickerVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchTextField: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var confirmBarButton: UIBarButtonItem!
    
    // MARK: - Properties
    weak var delegate: ImagePickerDelegate?
    private var photos: [UnsplashPhoto] = []
    private var selectedIndexPath: IndexPath?
    private var selectedImage: UIImage?
    private var selectedPhotoData: UnsplashPhoto?
    
    private let accessKey = "icTlumgLa3IIY8sVnRmz3laOMX_N2XWLelCgxGAUW40"
    private let imageCache = NSCache<NSString, UIImage>()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        searchImages(query: "travel")
    }
    
    // MARK: - Setup
    private func setupUI() {
        searchTextField.delegate = self
        searchTextField.searchBarStyle = .minimal
        searchTextField.placeholder = "Search images..."
        confirmBarButton.isEnabled = false
        
        // Loading indicator
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        let totalPadding: CGFloat = 32 + 16
        let width = (view.bounds.width - totalPadding) / 3
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - Actions
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func confirmTapped(_ sender: UIBarButtonItem) {
        guard let image = selectedImage, let photoData = selectedPhotoData else { return }
        delegate?.didSelectImage(image, photoData: photoData)
        dismiss(animated: true)
    }
    
    @objc private func performSearch() {
        guard let query = searchTextField.text, !query.isEmpty else { return }
        searchImages(query: query)
    }
    
    // MARK: - Networking
    private func searchImages(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.unsplash.com/search/photos?query=\(encodedQuery)&per_page=30&client_id=\(accessKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    print("Error fetching images: \(error?.localizedDescription ?? "Unknown error")")
                }
                return
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(UnsplashSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.photos = searchResponse.results
                    self.selectedIndexPath = nil
                    self.selectedImage = nil
                    self.selectedPhotoData = nil
                    self.confirmBarButton.isEnabled = false
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self.imageCache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

// MARK: - UICollectionViewDataSource
extension CD04_ImagePickerVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let photo = photos[indexPath.item]
        
        cell.isSelectedCell = (indexPath == selectedIndexPath)
        
        // Check cache first
        if let cachedImage = imageCache.object(forKey: photo.urls.small as NSString) {
            cell.imageView.image = cachedImage
        } else {
            cell.imageView.image = nil
            loadImage(from: photo.urls.small) { image in
                if let currentIndexPath = collectionView.indexPath(for: cell), currentIndexPath == indexPath {
                    cell.imageView.image = image
                }
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CD04_ImagePickerVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        selectedPhotoData = photos[indexPath.item]
        
        loadImage(from: photos[indexPath.item].urls.regular) { [weak self] image in
            self?.selectedImage = image
            self?.confirmBarButton.isEnabled = (image != nil)
        }
        
        var indexPathsToReload: [IndexPath] = [indexPath]
        if let previous = previousIndexPath {
            indexPathsToReload.append(previous)
        }
        
        collectionView.reloadItems(at: indexPathsToReload)
    }
}

// MARK: - UISearchBarDelegate
extension CD04_ImagePickerVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchImages(query: "travel")
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.5)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Custom Image Cell
class ImageCell: UICollectionViewCell {
    
    // MARK: - Outlets (connected in SD04_ImagePicker.storyboard)
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkmarkView: UIView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    var isSelectedCell: Bool = false {
        didSet {
            checkmarkView.isHidden = !isSelectedCell
        }
    }
}
