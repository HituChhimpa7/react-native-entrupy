# react-native-entrupy

React Native wrapper for Entrupy SDK

## Installation


```sh
npm install react-native-entrupy
```


## Usage


```js
import { startCapture, generateAuthorizationRequest } from 'react-native-entrupy';

// Example: Start a capture session
const handleCapture = async () => {
  const isSuccess = await startCapture('Bags', 'Gucci', 'Handbag', 'item_12345');
  console.log('Capture success:', isSuccess);
};
```


## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
