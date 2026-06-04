# react-native-entrupy

A robust, developer-friendly React Native wrapper for the Entrupy SDK. This library allows you to easily integrate Entrupy's authentication and capture services into your React Native iOS and Android applications.

---

## 🛑 Prerequisites (Important)

Before you begin, you **must** register your application with Entrupy:

1. **Register Package Names:** You need to register your Android `applicationId` and iOS `Bundle Identifier` on the Entrupy Developer Portal. If these are not registered, the SDK will fail to authenticate.
2. **Entrupy Credentials:** Obtain your Entrupy access tokens/keys from your Entrupy dashboard.
3. **Private Repository Access:** If this repository is hosted privately, ensure that the user installing it has their Git username and Personal Access Token (PAT) configured in their system to fetch the package.

---

## 📦 Installation

Install the package using your preferred package manager:

```sh
# Using npm
npm install react-native-entrupy

# Using yarn
yarn add react-native-entrupy
```

### 🍎 iOS Setup

After installing the package, you need to install the iOS dependencies via CocoaPods:

```sh
cd ios
pod install
cd ..
```

*Note: Make sure your iOS deployment target in `Podfile` matches the Entrupy SDK minimum requirements (usually iOS 13.0+).*

### 🤖 Android Setup

Typically, auto-linking handles everything for Android. However, ensure that your `minSdkVersion` in `android/build.gradle` is set to the minimum version required by the Entrupy SDK (usually API 24+).

---

## 🛠 Usage

Here is a complete example of how to use the SDK in your app:

```tsx
import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { startCapture, generateAuthorizationRequest } from 'react-native-entrupy';

export default function App() {
  const [status, setStatus] = useState<string>('Ready');

  const handleStartCapture = async () => {
    try {
      setStatus('Starting capture session...');
      // Make sure your bundle ID / package name is registered on Entrupy!
      const isSuccess = await startCapture('Bags', 'Gucci', 'Handbag', 'item_12345');
      setStatus(`Capture Success: ${isSuccess}`);
    } catch (error: any) {
      setStatus(`Error: ${error.message}`);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.status}>Status: {status}</Text>
      <Button title="Start Entrupy Capture" onPress={handleStartCapture} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  status: { fontSize: 16, marginBottom: 20, fontWeight: 'bold' },
});
```

---

## 🧹 Troubleshooting & Clean Builds

Sometimes React Native caches can cause issues. If you face any native build errors, run the following commands to clean your project:

### Clean Android
```sh
cd android
./gradlew clean
cd ..
# To rebuild
npx react-native run-android
```

### Clean iOS
```sh
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
# To rebuild
npx react-native run-ios
```

### Clean React Native Cache (Metro)
```sh
npm start -- --reset-cache
# or with Yarn
yarn start --reset-cache
```

---

## 🤝 Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## 📄 License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
