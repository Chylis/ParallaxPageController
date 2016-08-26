# ParallaxPageController

## Description:
- A page based scroll view with a configurable parallax effect. Useful for e.g. tutorial/onboarding scenes.
- Supports both Portrait and Landscape
- Configurable:
  - background and foreground parallax effects ("reveal" vs "appear" transition styles) 
  - background and foreground parallax speeds (0 == no parallax, 1 == increased parallax, etc)
  - foreground horizontal parallax motion effect, applied when moving device
  - border style (visibility, color, width)
  - UIPageControl (public access)

### Transition effect style examples

#### Background Reveal, Foreground Reveal (both parallax speeds are set to UIScreen.main.bounds.width / 100)
![reveal_reveal](https://cloud.githubusercontent.com/assets/653946/17971540/87d98bd0-6adb-11e6-948d-47c041c6ad60.gif)

#### Background Reveal, Foreground Appear
![reveal_appear](https://cloud.githubusercontent.com/assets/653946/17971531/815a1982-6adb-11e6-99d8-1915218efbfa.gif)

#### Background Appear, Foreground Appear
![appear_appear](https://cloud.githubusercontent.com/assets/653946/17971518/78824046-6adb-11e6-953c-4b1b3e60d94c.gif)

#### Background Appear, Foreground Reveal
![appear_reveal](https://cloud.githubusercontent.com/assets/653946/17971511/726ad9ac-6adb-11e6-9b64-559b9caa348a.gif)

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
  //Note: It is also possible to use a custom view controller's view as the background view 
  //(instead of an image) by creating a PageContent using: 
  //the "PageContent(backgroundController: bg1, foregroundController: fg1)" constructor

  let vc2 = ImageViewController(image: UIImage(named: "icon-pokedex")!, name: "2")
  let image2 = UIImage(named: "bulbasaur")!
  let page2 = PageContent(backgroundImage: image2, foregroundController: vc2)

  let vc3 = ImageViewController(image: UIImage(named: "icon-nintendo")!, name: "3")
  let image3 = UIImage(named: "charmander")!
  let page3 = PageContent(backgroundImage: image3, foregroundController: vc3)

  let vc4 = ImageViewController(image: UIImage(named: "icon-pikachu")!, name: "4")
  let image4 = UIImage(named: "squirtle")!
  let page4 = PageContent(backgroundImage: image4, foregroundController: vc4)

  //2. Create the ParallaxPageController:
  let parallaxVc = ParallaxPageControllerFactory.make(pages: [page1,page2,page3,page4])

  //3. Configure the ParallaxPageController:
  parallaxVc.view.backgroundColor = UIColor.white //To match the white background of the background images
  parallaxVc.backgroundParallaxSpeedFactor = 1
  parallaxVc.backgroundTransitionEffect = .reveal
  parallaxVc.foregroundParallaxSpeedFactor = 3
  parallaxVc.foregroundTransitionEffect = .appear
  parallaxVc.applyHorizontalMotionEffect = true
  parallaxVc.motionEffectStrength = 10
  parallaxVc.showBorders = true
  parallaxVc.borderWidth = 1
  parallaxVc.borderColor = UIColor.black
  parallaxVc.pageControl.pageIndicatorTintColor = UIColor.black
  parallaxVc.pageControl.currentPageIndicatorTintColor = UIColor.red


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
## TODO:
- Configurable background image content mode

Feel free to contribute!
