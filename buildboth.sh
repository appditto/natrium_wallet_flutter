#!/bin/bash
cd ios/
fastlane deploy &
cd ../android
fastlane deploy &