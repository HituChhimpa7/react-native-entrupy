import Entrupy from './NativeEntrupy';

export function generateAuthorizationRequest(): Promise<string> {
  return Entrupy.generateAuthorizationRequest();
}

export function loginUser(signedRequest: string): Promise<boolean> {
  return Entrupy.loginUser(signedRequest);
}

export function startCapture(
  productCategory: string,
  brand: string,
  itemType: string,
  itemId: string
): Promise<boolean> {
  return Entrupy.startCapture(productCategory, brand, itemType, itemId);
}

export default Entrupy;
