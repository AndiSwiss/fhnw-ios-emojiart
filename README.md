# FHNW iOS EmojiArt

An iOS EmojiArt application.

This project was created for the course [iOS](https://www.fhnw.ch/de/studium/module/9352170) at [FHNW University](https://www.fhnw.ch), held in 2021/2022.

## Contributors:

- [AndiSwiss](https://github.com/AndiSwiss)

- [chdabre](https://github.com/chdabre)



## Features

- Runs with iOS15





## Tests with Fastlane

Run tests with [Fastlane](https://fastlane.tools/):

- There are three test lanes as described in the Fastlane [README.md](fastlane/README.md) and as shown here (excerpt from Fastfile):

  ```bash
  lane :tests do
    run_tests(devices: ["iPhone 13", "iPad Pro (12.9-inch) (5th generation)"],
              scheme: "All in EmojiArtTests.swift")
  end
  
  
  lane :tests_ui do
    run_tests(devices: ["iPhone 13", "iPad Pro (12.9-inch) (5th generation)"],
              scheme: "All in EmojiArtUITests.swift")
  end
  
  
  lane :tests_ui_launch do
    run_tests(devices: ["iPhone 13", "iPad Pro (12.9-inch) (5th generation)"],
              scheme: "All in EmojiArtUITestsLaunchTests.swift")
  end
  ```

- Each test will be executed on two devices: *iPhone 13* and *iPad Pro (12.9-inch) (5th generation)*

- NOTE: Sometimes, the tests cannot be executed and instead a warning is shown:

  ```
  Couldn't find specified scheme 'All in EmojiArtTests.swift'. Please make sure that the scheme is shared, see https://developer.apple.com/library/content/documentation/IDEs/Conceptual/xcode_guide-continuous_integration/ConfigureBots.html#//apple_ref/doc/uid/TP40013292-CH9-SW3
  ```

  - **Cause:** It seems that XCode forgets sometimes, that it should share these schemes
  - **Solution:** Xcode => Menu Product => Scheme => Manage Schemes...:
    - Activate all Schemes to **Shared**



