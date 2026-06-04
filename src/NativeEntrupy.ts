import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  generateAuthorizationRequest(): Promise<string>;
  loginUser(signedRequest: string): Promise<boolean>;
  startCapture(
    productCategory: string,
    brand: string,
    itemType: string,
    itemId: string
  ): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Entrupy');
