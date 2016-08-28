//
//  ParallaxScrollViewController.swift
//  ParallaxPageController
//
//  Created by Magnus Eriksson on 22/08/16.
//  Copyright © 2016 Magnus Eriksson. All rights reserved.
//

import Foundation

public struct ParallaxScrollViewControllerFactory {
    
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
    
    public let backgroundController: UIViewController
    public let foregroundController: UIViewController
    
    public init(backgroundImage: UIImage, foregroundController: UIViewController) {
        self.backgroundController = ImageControllerFactory.make(image: backgroundImage)
        self.foregroundController = foregroundController
    }
    
    public init(backgroundController: UIViewController, foregroundController: UIViewController) {
        self.backgroundController = backgroundController
        self.foregroundController = foregroundController
    }
}


public protocol ParallaxScrollViewControllerDelegate {
    
    /**
     Called when the ParallaxScrollViewController is transitioning between two pages.
     
     - parameter parallaxScrollViewController: The ParallaxScrollViewController
     - parameter sourcePage: The source page of the transition
     - parameter destinationPage: The destination page of the transition
     - parameter progress: A value between 0 and 1, indicating the transition progress.
     */
    func parallaxScrollViewController(_ parallaxScrollViewController: ParallaxScrollViewController,
                                      isTransitioningFrom sourcePage: PageContent,
                                      to destinationPage: PageContent,
                                      with progress: CGFloat)
}

/*

 The ParallaxScrollViewController' view hierarchy is built up as follows:

 * ParallaxScrollViewController view
 |   |   * Background scrollview
 |   |   |   * Background stackview
 |   |   |   |   * For each page:
 |   |   |   |   |   * Scrollview
 |   |   |   |   |   |   * Page BackgroundController's view
 |   |   * Foreground scrollview
 |   |   |   * Foreground stackview
 |   |   |   |   * For each page:
 |   |   |   |   |   * Scrollview
 |   |   |   |   |   |   * Page ForegroundController's view
*/

public class ParallaxScrollViewController: UIViewController {
    
    public enum TransitionEffect: Int {
        ///A "revealing" effect. The opposite of appear. Combine with "backgroundParallaxSpeedFactor = (UIScreen.main.bounds.width / 100)" for a curtain-like effect.
        case reveal = -1
        
        ///An "appearing" effect. The opposite of reveal.
        case appear = 1
    }
    
    //MARK: Public
    
    public var delegate: ParallaxScrollViewControllerDelegate?
    
    @IBOutlet public weak var pageControl: UIPageControl!
    
    ///The transition effect to apply to the background view when scrolling
    public var backgroundTransitionEffect = TransitionEffect.reveal
    
    ///The transition effect to apply to the foreground view when scrolling
    public var foregroundTransitionEffect = TransitionEffect.appear
    
    //The amount of speed to apply to the background parallax effect. Larger values result in a greater parallax effect. A value of 0 disables the parallax effect.
    public var backgroundParallaxSpeedFactor: CGFloat = 1
    
    ///The amount of speed to apply to the foreground parallax effect. Larger values result in a greater parallax effect. A value of 0 disables the parallax effect.
    public var foregroundParallaxSpeedFactor: CGFloat = 1.5
    
    ///If a horizontal motion effect should be applied to the foreground view
    public var applyHorizontalMotionEffect = true {
        didSet {
            updateMotionEffect()
        }
    }
    
    ///The strength of the motion effect applied to the foreground view
    public var motionEffectStrength = 10 {
        didSet {
            updateMotionEffect()
        }
    }
    
    ///If borders between the pages should be visible or not
    public var showBorders = false {
        didSet {
            updateBorders()
        }
    }
    
    ///The width of the page borders
    public var borderWidth: CGFloat = 1.5 {
        didSet {
            updateBorders()
        }
    }
    
    ///The color of the page borders
    public var borderColor = UIColor.black {
        didSet {
            updateBorders()
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
            sendWill(disappear: currentPageIndex, appear: newValue)
        }
        didSet {
            guard oldValue != currentPageIndex else {
                return
            }
            sendDid(disappear: oldValue, appear: currentPageIndex)
            
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
    
    //MARK: View controller life cycle
    
    override public var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendWill(disappear: nil, appear: currentPageIndex, animated: animated)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sendDid(disappear: nil, appear: currentPageIndex)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sendWill(disappear: currentPageIndex, appear: nil, animated: animated)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sendDid(disappear: currentPageIndex, appear: nil)
    }
    
    /**
     * - Sends 'viewWillDisappear' to the controllers at index 'from'
     * - Sends 'viewWillAppear' to the controllers at index 'to'
     */
    private func sendWill(disappear: Int?, appear: Int?, animated: Bool = true) {
        if let disappear = disappear {
            let previousPage = pages[disappear]
            previousPage.backgroundController.beginAppearanceTransition(false, animated: animated)
            previousPage.foregroundController.beginAppearanceTransition(false, animated: animated)
        }
        
        if let appear = appear {
            let nextPage = pages[appear]
            nextPage.backgroundController.beginAppearanceTransition(true, animated: animated)
            nextPage.foregroundController.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    /**
     * - Sends 'viewWDidDisappear' to the controllers at index 'from'
     * - Sends 'viewDidAppear' to the controllers at index 'to'
     */
    private func sendDid(disappear: Int?, appear: Int?) {
        if let disappear = disappear {
            let previousPage = pages[disappear]
            previousPage.backgroundController.endAppearanceTransition()
            previousPage.foregroundController.endAppearanceTransition()
        }
        
        if let appear = appear {
            let currentPage = pages[appear]
            currentPage.backgroundController.endAppearanceTransition()
            currentPage.foregroundController.endAppearanceTransition()
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
    
    private func updateMotionEffect() {
            for page in pages {
                let view = page.foregroundController.view!
                view.motionEffects.forEach { view.removeMotionEffect($0)}
                if applyHorizontalMotionEffect {
                    view.addMotionEffect(UIMotionEffect.make(strength: motionEffectStrength, type: .tiltAlongHorizontalAxis))
                }
        }
    }
    
    ///Adds all the pages to self
    private func add(pages: [PageContent]) {
        for page in pages {
            add(controller: page.backgroundController, to: backgroundStackView)
            add(controller: page.foregroundController, to: foregroundStackView)
        }
    }
    
    private func add(controller: UIViewController, to stackview: UIStackView) {
        addChildViewController(controller)
        
        let controllerView = controller.view!
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = false
        scrollView.center(subview: controllerView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackview.addArrangedSubview(scrollView)
        
        //Set scroll view content size
        controllerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        controllerView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        //Set scroll view size
        scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
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
    fileprivate func backgroundControllerScrollView(at index: Int) -> UIScrollView? {
        guard index >= 0 && index < pages.count else {
            return nil
        }
        guard let scrollView = pages[index].backgroundController.view.superview as? UIScrollView else {
            fatalError("Background controller's superview must be a scrollView")
        }
        return scrollView
    }
}




//MARK: UIScrollViewDelegate

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
                let backgroundSourceScrollView = backgroundControllerScrollView(at: transitionSourceElementIndex)!
                let foregroundSourceScrollView = foregroundControllerScrollView(at: transitionSourceElementIndex)!
                let backgroundDestinationScrollView = backgroundControllerScrollView(at: transitionDestinationElementIndex)
                let foregroundDestinationScrollView = foregroundControllerScrollView(at: transitionDestinationElementIndex)

                //Calculate source XOffsets
                backgroundSourceScrollView.contentOffset.x = applyBackgroundParallaxEffect(to: sourceTransitionProgressPercentage)
                foregroundSourceScrollView.contentOffset.x = applyForegroundParallaxEffect(to: sourceTransitionProgressPercentage)
                
                //Calculate destination XOffsets
                backgroundDestinationScrollView?.contentOffset.x = applyBackgroundParallaxEffect(to: destTransitionProgressPercentage)
                foregroundDestinationScrollView?.contentOffset.x = applyForegroundParallaxEffect(to: destTransitionProgressPercentage)
                
                //Keep background scroll view in sync with foreground scroll view
                self.backgroundScrollView.contentOffset = scrollView.contentOffset
                
                
                notifyDelegateOfTransition(fromIndex: transitionSourceElementIndex,
                                           toIndex: transitionDestinationElementIndex,
                                           progress: sourceTransitionProgress)
            }
        }
    
    private func applyBackgroundParallaxEffect(to value: CGFloat) -> CGFloat {
        return value * backgroundParallaxSpeedFactor * CGFloat(backgroundTransitionEffect.rawValue)
    }
    
    private func applyForegroundParallaxEffect(to value: CGFloat) -> CGFloat {
        return value * foregroundParallaxSpeedFactor * CGFloat(foregroundTransitionEffect.rawValue)
    }
    
    private func notifyDelegateOfTransition(fromIndex: Int, toIndex: Int, progress: CGFloat) {
        guard progress != 0, fromIndex >= 0, toIndex < pages.count else {
            return
        }
        
//        print("From: \(fromIndex), to: \(toIndex), progress: \(normalisedProgress)")
        let normalisedProgress = abs(progress)
        self.delegate?.parallaxScrollViewController(self,
                                                    isTransitioningFrom: pages[fromIndex],
                                                    to: pages[toIndex],
                                                    with: normalisedProgress)
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
