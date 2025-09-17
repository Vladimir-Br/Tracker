
import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Properties
    
    private lazy var pages: [UIViewController] = [
        createPage(
            description: "Отслеживайте только то, что хотите",
            imagePage: "Page1"
        ),
        createPage(
            description: "Даже если это не литры воды и йога",
            imagePage: "Page2"
        )
    ]
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = UIColor(resource: .blackDay)
        pageControl.pageIndicatorTintColor = UIColor(resource: .grayDay)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .blackDay)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .white
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(pageControl)
        view.addSubview(skipButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
           
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.heightAnchor.constraint(equalToConstant: 60),
        
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -24)
        ])
    }
    
    private func createPage(description: String, imagePage: String) -> UIViewController {
        let viewController = UIViewController()
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: imagePage)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = description
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = UIColor(resource: .blackDay)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.addSubview(imageView)
        viewController.view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
           
            imageView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
           
            titleLabel.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: -270),
            titleLabel.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16)
        ])
        
        return viewController
    }
    
    @objc private func skipButtonTapped() {
        finishOnboarding()
    }
    
    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let coreDataManager = appDelegate.coreDataManager else {
            assertionFailure("CoreDataManager не инициализирован")
            return
        }
        
        let tabBarController = TabBarController(coreDataManager: coreDataManager)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        window.rootViewController = tabBarController
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
