//
//  ParallaxScrollViewController.swift
//  ParallaxPageController
//
//  Created by Magnus Eriksson on 22/08/16.
//  Copyright © 2016 Magnus Eriksson. All rights reserved.
//

import Foundation

public struct ParallaxPageControllerFactory {
    
    static public func make(pages: [PageContent]) -> ParallaxScrollViewController {
        
        let nib = UINib(nibName: String(describing: ParallaxScrollViewController.self),
                        bundle: Bundle(for: ParallaxScrollViewController.self))
            .instantiate(withOwner: nil, options: nil)
        
        let vc = nib.first as! ParallaxScrollViewController
        vc.pages = pages
        return vc
    }
}

public struct PageContent {
    
    let backgroundImageController: ScrollableImageController
    let foregroundController: UIViewController
    
    public init(backgroundImage: UIImage, controller: UIViewController) {
        self.backgroundImageController = ScrollableImageControllerFactory.make(image: backgroundImage)
        self.foregroundController = controller
    }
}

public class ParallaxScrollViewController: UIViewController {
    
    public enum TransitionEffect: Int {
        ///A "revealing" effect. Combine with friction = 1 for a curtain-like effect.
        case reveal = -1
        
        ///An "appearing" effect.
        case appear = 1
    }
    
    //MARK: Public
    
    @IBOutlet public weak var pageControl: UIPageControl!
    
    public var transitionEffect = TransitionEffect.reveal
    
    public var borderWidth: CGFloat = 1.5 {
        didSet {
            updateBorders()
        }
    }
    
    public var borderColor = UIColor.black {
        didSet {
            updateBorders()
        }
    }
    
    public var showBorders = false {
        didSet {
            updateBorders()
        }
    }
    
    ///The amount of friction to apply to the background parallax effect. Lesser values result in a greater parallax effect. Must be > 0.
    public var parallaxFrictionFactor: CGFloat = 3 {
        willSet {
            guard newValue > 0 else {
                fatalError("parallaxFrictionFactor must be larger than 0")
            }
        }
    }
    
    
    //MARK: IBOutlets
    
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet weak var backgroundStackView: UIStackView!
    
    @IBOutlet weak var foregroundScrollView: UIScrollView!
    @IBOutlet weak var foregroundStackView: UIStackView!
    
    
    //MARK: Properties
    
    fileprivate var pages: [PageContent] = [] {
        willSet {
            //TODO: remove previous pages
        }
        didSet {
            add(pages: pages)
            pageControl.numberOfPages = pages.count
        }
    }
    
    //Keeps track of the current page index in order to track scroll direction (i.e. if scrolling backwards or forwards)
    fileprivate var currentPageIndex: Int = 0 {
        willSet {
            guard newValue != currentPageIndex else {
                return
            }
            
            let newForegroundController = pages[newValue].foregroundController
            newForegroundController.beginAppearanceTransition(true, animated: false)
        }
        didSet {
            guard oldValue != currentPageIndex else {
                return
            }
            
            let foregroundController = pages[currentPageIndex].foregroundController
            foregroundController.endAppearanceTransition()
            
            //Update page control
            pageControl.currentPage = currentPageIndex
        }
    }
    
    //The current page before the trait collection changes, e.g. prior to rotation occurrs
    private var pageIndexBeforeTraitCollectionChange: Int = 0
    
    //MARK: Rotation related events
    
    override public func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        pageIndexBeforeTraitCollectionChange = foregroundScrollView.currentPage()
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        //Restore previous page.
        //A slight delay is required since the scroll view's frame size has not yet been updated to reflect the new trait collection.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            CATransaction.begin()
            self.foregroundScrollView.scrollToPageAtIndex(self.pageIndexBeforeTraitCollectionChange, animated: true)
            CATransaction.commit()
        }
    }
    
    
    //MARK: Private
    
    private func updateBorders() {
        for page in pages {
            let view = page.foregroundController.view!
            view.layer.borderWidth = showBorders ? borderWidth : 0
            view.layer.borderColor = borderColor.cgColor
        }
    }
    
    ///Adds all the pages to self
    private func add(pages: [PageContent]) {
        for page in pages {
            add(page.backgroundImageController, to: backgroundStackView)
            add(page.foregroundController, to: foregroundStackView)
        }
    }

    ///Adds the received view controller to self.childViewControllers and adds it's view to to received stack view
    private func add(_ childViewController: UIViewController, to stackView: UIStackView) {
        addChildViewController(childViewController)
        stackView.addArrangedSubview(childViewController.view)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        childViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        childViewController.view.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        childViewController.didMove(toParentViewController: self)
    }
    
    ///Returns the scrollable image view controller at the received index, or nil if the index is out of bounds
    fileprivate func scrollableImageController(at index: Int) -> ScrollableImageController? {
        guard index >= 0 && index < pages.count else {
            return nil
        }
        return pages[index].backgroundImageController
    }
}

extension ParallaxScrollViewController: UIScrollViewDelegate {
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView == foregroundScrollView {
                
                let isGoingBackwards = scrollView.currentPage() < currentPageIndex
                
                //"percentScrolledInPage" represents the X-scroll percentage within the current page, starting at index 0.
                //E.g. if the scroll view is 50% between page 5 and 6, the  will be 4.5
                let percentScrolledInPage = scrollView.horizontalPercentScrolledInCurrentPage()
                
                //The transition progress of the leftmost page involved in the transition
                let leftTransitionProgress = percentScrolledInPage - CGFloat(scrollView.currentPage())
                
                //The transition progress of the rightmost page involved in the transition (the opposite of the leftTransitionProgress)
                let rightTransitionProgress = (1 - leftTransitionProgress)
                
                //The transition progress of the current/source page
                let sourceTransitionProgress = isGoingBackwards ? rightTransitionProgress : leftTransitionProgress
                
                //The transition progress of the destination page
                let destTransitionProgress = isGoingBackwards ? leftTransitionProgress : rightTransitionProgress
                
                //The index of the leftmost element involved in the transition
                let transitionLeftElementIndex = scrollView.currentPage()
                
                //The index of the rightmost element involved in the transition
                let transitionRightElementIndex = transitionLeftElementIndex + 1
                
                //The index of the transition source element
                let transitionSourceElementIndex = isGoingBackwards ? transitionRightElementIndex : transitionLeftElementIndex
                
                //The index of the transition destination element
                let transitionDestinationElementIndex = isGoingBackwards ? transitionLeftElementIndex : transitionRightElementIndex
                
                let sourceScrollView = scrollableImageController(at: transitionSourceElementIndex)!.scrollView!
                let destinationScrollView = scrollableImageController(at: transitionDestinationElementIndex)?.scrollView!
                
                let pageSize = sourceScrollView.pageSize()
                
                //Calculate source XOffset
                var sourceXOffset = (pageSize * sourceTransitionProgress) / parallaxFrictionFactor
                
                //Apply the appropriate parallax effect
                sourceXOffset *= CGFloat(transitionEffect.rawValue)
                
                //Consider direction
                if isGoingBackwards {
                    sourceXOffset *= -1
                }
                
                var destXOffset = (pageSize * destTransitionProgress) / parallaxFrictionFactor
                destXOffset *= CGFloat(transitionEffect.rawValue)
                if !isGoingBackwards {
                    destXOffset *= -1
                }
                
                //Scroll the background view controllers' scroll views
                sourceScrollView.contentOffset.x = sourceXOffset
                destinationScrollView?.contentOffset.x = destXOffset
                
                //Keep background scroll view in sync with foreground scroll view
                self.backgroundScrollView.contentOffset = scrollView.contentOffset
            }
        }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == foregroundScrollView {
            //Save the current page index
            currentPageIndex = scrollView.currentPage()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == foregroundScrollView {
            //Save the current page index
            currentPageIndex = scrollView.currentPage()
        }
    }
}
