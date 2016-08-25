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

/*

 The ParallaxScrollViewController' view hierarchy is built up as follows:

 * ParallaxScrollViewController view
 |   |   * Background scrollview
 |   |   |   * Background stackview
 |   |   |   |   * For each page: ScrollableImageController view
 |   |   |   |   |   * scrollview
 |   |   |   |   |   |   * contentview
 |   |   |   |   |   |   |   * page imageview
 |   |   * Foreground scrollview
 |   |   |   * Foreground stackview
 |   |   |   |   * For each page: scrollview
 |   |   |   |   |   * Foregroundcontroller's view
*/

public class ParallaxScrollViewController: UIViewController {
    
    public enum TransitionEffect: Int {
        ///A "revealing" effect. The opposite of appear. Combine with "backgroundParallaxSpeedFactor = (UIScreen.main.bounds.width / 100)" for a curtain-like effect.
        case reveal = -1
        
        ///An "appearing" effect. The opposite of reveal.
        case appear = 1
    }
    
    //MARK: Public
    
    @IBOutlet public weak var pageControl: UIPageControl!
    
    public var backgroundTransitionEffect = TransitionEffect.reveal
    public var foregroundTransitionEffect = TransitionEffect.appear
    
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
    
    ///The amount of speed to apply to the background parallax effect. Larger values result in a greater parallax effect. A value of 0 disables the parallax effect.
    public var backgroundParallaxSpeedFactor: CGFloat = 1
    
    ///The amount of speed to apply to the foreground parallax effect. Larger values result in a greater parallax effect. A value of 0 disables the parallax effect.
    public var foregroundParallaxSpeedFactor: CGFloat = 3
    
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
            
            //Send viewWillDisappear
            let previousForegroundController = pages[currentPageIndex].foregroundController
            previousForegroundController.beginAppearanceTransition(false, animated: false)
            
            //Send viewWillAppear
            let newForegroundController = pages[newValue].foregroundController
            newForegroundController.beginAppearanceTransition(true, animated: false)
        }
        didSet {
            guard oldValue != currentPageIndex else {
                return
            }
            
            //Send viewDidDisappear
            let previousForegroundController = pages[oldValue].foregroundController
            previousForegroundController.endAppearanceTransition()
            
            //Send viewDidAppear
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
        for index in 0..<pages.count {
            let scrollview = foregroundControllerScrollView(at: index)!
            scrollview.layer.borderWidth = showBorders ? borderWidth : 0
            scrollview.layer.borderColor = borderColor.cgColor
        }
    }
    
    ///Adds all the pages to self
    private func add(pages: [PageContent]) {
        for page in pages {
            add(page.backgroundImageController, to: backgroundStackView)
            add(foregroundController: page.foregroundController, to: foregroundStackView)
        }
    }
    
    private func add(foregroundController: UIViewController, to stackview: UIStackView) {
        //TODO: Use this for background view controller too
        
        addChildViewController(foregroundController)
        
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = false
        let view = foregroundController.view!
        
        scrollView.addSubview(view)
        stackview.addArrangedSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            view.heightAnchor.constraint(equalTo: self.view.heightAnchor),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
            ])
        
        foregroundController.didMove(toParentViewController: self)
    }

    ///Adds the received view controller to self.childViewControllers and adds it's view to to received stack view
    private func add(_ childViewController: UIViewController, to stackView: UIStackView) {
        //TODO: Remove when above is used for background controller too
        addChildViewController(childViewController)
        stackView.addArrangedSubview(childViewController.view)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        childViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        childViewController.view.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        childViewController.didMove(toParentViewController: self)
    }
    
    ///Returns the scroll view that contains the foreground controller's view at the received index, or nil if the index is out of bounds
    fileprivate func foregroundControllerScrollView(at index: Int) -> UIScrollView? {
        guard index >= 0 && index < pages.count else {
            return nil
        }
        guard let scrollView = pages[index].foregroundController.view.superview as? UIScrollView else {
            fatalError("Foreground controller's superview must be a scrollView")
        }
        return scrollView
    }
    
    ///Returns the scrollable image view controller at the received index, or nil if the index is out of bounds
    fileprivate func backgroundController(at index: Int) -> ScrollableImageController? {
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
                let sourceTransitionProgress = isGoingBackwards ? -rightTransitionProgress : leftTransitionProgress
                let sourceTransitionProgressPercentage = sourceTransitionProgress * 100
                
                //The transition progress of the destination page
                let destTransitionProgress = isGoingBackwards ? leftTransitionProgress : -rightTransitionProgress
                let destTransitionProgressPercentage = destTransitionProgress * 100
                
                //The index of the leftmost element involved in the transition
                let transitionLeftElementIndex = scrollView.currentPage()
                
                //The index of the rightmost element involved in the transition
                let transitionRightElementIndex = transitionLeftElementIndex + 1
                
                //The index of the transition source element
                let transitionSourceElementIndex = isGoingBackwards ? transitionRightElementIndex : transitionLeftElementIndex
                
                //The index of the transition destination element
                let transitionDestinationElementIndex = isGoingBackwards ? transitionLeftElementIndex : transitionRightElementIndex
                
                //Fetch scroll views involved in the transition
                let backgroundSourceScrollView = backgroundController(at: transitionSourceElementIndex)!.scrollView!
                let foregroundSourceScrollView = foregroundControllerScrollView(at: transitionSourceElementIndex)!
                let backgroundDestinationScrollView = backgroundController(at: transitionDestinationElementIndex)?.scrollView!
                let foregroundDestinationScrollView = foregroundControllerScrollView(at: transitionDestinationElementIndex)

                //Calculate source XOffsets
                backgroundSourceScrollView.contentOffset.x = applyBackgroundParallaxEffect(to: sourceTransitionProgressPercentage)
                foregroundSourceScrollView.contentOffset.x = applyForegroundParallaxEffect(to: sourceTransitionProgressPercentage)
                
                //Calculate destination XOffsets
                backgroundDestinationScrollView?.contentOffset.x = applyBackgroundParallaxEffect(to: destTransitionProgressPercentage)
                foregroundDestinationScrollView?.contentOffset.x = applyForegroundParallaxEffect(to: destTransitionProgressPercentage)
                
                //Keep background scroll view in sync with foreground scroll view
                self.backgroundScrollView.contentOffset = scrollView.contentOffset
            }
        }
    
    private func applyBackgroundParallaxEffect(to value: CGFloat) -> CGFloat {
        return value * backgroundParallaxSpeedFactor * CGFloat(backgroundTransitionEffect.rawValue)
    }
    
    private func applyForegroundParallaxEffect(to value: CGFloat) -> CGFloat {
        return value * foregroundParallaxSpeedFactor * CGFloat(foregroundTransitionEffect.rawValue)
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
