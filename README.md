# ParallaxPageController

## Description:
- A page based scroll view with a configurable parallax effect. Useful for e.g. tutorial/onboarding scenes.
- Supports both Portrait and Landscape
- Configurable:
  - parallax effect ("reveal" vs "appear" transition styles + friction)
  - border style (visibility, color, width)
  - UIPageControl (public access)

### Transition effect styles
#### Reveal
![reveal_style](https://cloud.githubusercontent.com/assets/653946/17932755/c7239c7e-6a11-11e6-87f1-2ab52a92a5f9.gif)

#### Appear
![appear_style](https://cloud.githubusercontent.com/assets/653946/17932692/83d85a5e-6a11-11e6-8609-435a803a1c88.gif)

## Installation:
  - Fetch with Carthage, e.g:
  - 'github "apegroup/apegroup-parallaxpagecontroller-ios"'

## Usage example:
Get started with 3 easy steps:
  1. Set up pages to be presented in the ParallaxPageController (note that the foreground view controllers must have a transparent background in order to be able to view the background images)
 
  2. Create the ParallaxPageController

  3. Configure the ParallaxPageController

  ```swift
import ParallaxPageController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

  //1. Set up pages to be presented in the ParallaxPageController:
  let vc1 = ImageViewController(image: UIImage(named: "icon-pokeball")!, name: "1")
  let image1 = UIImage(named: "pikachu")!
  let page1 = PageContent(backgroundImage: image1, controller: vc1)

  let vc2 = ImageViewController(image: UIImage(named: "icon-pokedex")!, name: "2")
  let image2 = UIImage(named: "bulbasaur")!
  let page2 = PageContent(backgroundImage: image2, controller: vc2)

  let vc3 = ImageViewController(image: UIImage(named: "icon-nintendo")!, name: "3")
  let image3 = UIImage(named: "charmander")!
  let page3 = PageContent(backgroundImage: image3, controller: vc3)

  let vc4 = ImageViewController(image: UIImage(named: "icon-pikachu")!, name: "4")
  let image4 = UIImage(named: "squirtle")!
  let page4 = PageContent(backgroundImage: image4, controller: vc4)

  //2. Create the ParallaxPageController:
  let parallaxVc = ParallaxPageControllerFactory.make(pages: [page1,page2,page3,page4])

  //3. Configure the ParallaxPageController:
  parallaxVc.pageControl.pageIndicatorTintColor = UIColor.black
  parallaxVc.pageControl.currentPageIndicatorTintColor = UIColor.red
  parallaxVc.parallaxFrictionFactor = 4
  parallaxVc.showBorders = true
  parallaxVc.borderWidth = 1
  parallaxVc.borderColor = UIColor.black
  parallaxVc.transitionEffect = .reveal




  window = UIWindow()
  window?.rootViewController = parallaxVc
  window?.makeKeyAndVisible()
  return true
}
```

## Restrictions:
-- 
## Known Issues:
-- 


Feel free to contribute!
