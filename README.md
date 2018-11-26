# appium-snaphot-tests

Runs snapshot tests against screenshots generated during Appium tests and ones saved as originals.

## How to use this Step

Add step definition. 
```YML
 appium-snapshot-tests:
    steps:
      - git::https://github.com/Siemian/bitrise-step-appium-snaphot-tests:
          title: Appium Snapshot Tests
          inputs:
            - screenshots_directory: "SnapshotTests"
            - export_failed_artifacts: true
```

## About

This project is made with <3 by [Netguru](https://netguru.co/opensource).

### License

Licensed under the MIT License. See [LICENSE.MD](LICENSE.MD) for more info.