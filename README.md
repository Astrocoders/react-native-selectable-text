
# react-native-selectable-text

## Demo

### Android

<img src="https://github.com/Astrocoders/react-native-selectable-text/raw/master/Demo/demo_android.gif" width="350px" />

### iOS

<img src="https://github.com/Astrocoders/react-native-selectable-text/raw/master/Demo/demo_ios.gif" width="350px" />

## Usage
```javascript
import { SelectableText } from 'react-native-selectable-text';

// Use normally, it is a drop-in replacement for react-native/Text
<SelectableText
  menuItems={['Foo', 'Bar']}
  /* Called when the user taps in a item of the selection menu, eventType is the label and content the selected text portion */
  onSelection={({ eventType, content }) => {}}
  /* iOS only (RGB) */
  highlightColor={[255, 0, 0]}
>
  I crave star damage
</SelectableText>
```
  

## Getting started

`$ npm install react-native-selectable-text --save`

### Mostly automatic installation

`$ react-native link react-native-selectable-text`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-selectable-text` and add `RNSelectableText.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNSelectableText.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.astrocoders.selectabletext.RNSelectableTextPackage;` to the imports at the top of the file
  - Add `new RNSelectableTextPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-selectable-text'
  	project(':react-native-selectable-text').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-selectable-text/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-selectable-text')
  	```
