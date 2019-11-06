#!/bin/bash

cd ../../
if [ "$1" == "--clean" ]
then
   echo "Running clean..."
   flutter clean
else
   echo "Skipping clean..."
fi
if [ "$1" == "--apk" ]
then
   echo "Building APK..."
   flutter build apk --release
else
   echo "Building AAB..."
   flutter build appbundle --release
fi