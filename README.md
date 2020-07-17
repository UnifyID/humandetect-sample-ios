# HumanDetect Example (iOS app)

## A. Prerequisites

* Swift >= 4.2
* Xcode >= 11.4
* iOS >= 13.0.0

## B. Set up Flask server
* Follow the instructions for the [HumanDetect Example Flask app](https://github.com/UnifyID/humandetect-sample-flask) to set up the corresponding backend for this project.
* Set the `flaskURL` variable at the top of `ViewController.swift` to the URL that your Flask app is deployed at.

  ```
  let flaskURL = "<URL OF YOUR FLASK APP>"
  ```

## C. Generate Mobile SDK Key
* Follow the [Getting Started Guide](https://developer.unify.id/docs/get-started/) to create an account on the [UnifyID Developer Portal](https://dashboard.unify.id/account/sign-up).
* Generate an SDK key using the developer portal.
* Add your SDK key at the top of `AppDelegate.swift`.

  ```
  let unify : UnifyID = { try! UnifyID(
    sdkKey: "<YOUR SDK KEY>"
  )}()
  ```

## D. Next Steps
The iOS app is now ready! Open XCode and build/run the app on a physical device. Please note that a simulator will not work because a camera and physical sensors (for HumanDetect algorithms) are required.

Feel free to check out the following links for more info:
* Blog post on the [UnifyID blog](https://blog.unify.id/)
* [HumanDetect documentation](https://developer.unify.id/docs/humandetect/)
