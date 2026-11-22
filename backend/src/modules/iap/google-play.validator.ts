import { google } from 'googleapis';
import { env } from '../../config/env.js';

export interface VerifyPurchaseResult {
  isValid: boolean;
  orderId?: string;
  purchaseState?: number;
  consumptionState?: number;
  acknowledgementState?: number;
  productId: string;
  purchaseToken: string;
  grantedMinutes: number;
  isSubscription: boolean;
  tier?: string;
  message: string;
}

export class GooglePlayValidator {
  private static getPublisherClient() {
    if (!env.GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL || !env.GOOGLE_PLAY_PRIVATE_KEY) {
      return null;
    }

    const auth = new google.auth.JWT({
      email: env.GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL,
      key: env.GOOGLE_PLAY_PRIVATE_KEY.replace(/\\n/g, '\n'),
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });

    return google.androidpublisher({ version: 'v3', auth });
  }

  /**
   * Verifies In-App Purchases (one-time consumable coin packs or recurring subscriptions).
   */
  public static async verifyPurchase(params: {
    packageName: string;
    productId: string;
    purchaseToken: string;
    isSubscription?: boolean;
  }): Promise<VerifyPurchaseResult> {
    const publisher = this.getPublisherClient();

    // In local sandbox or when keys are pending, return simulated validation for development
    if (!publisher) {
      console.log('Google Play Service Account credentials not provided; validating via sandbox dev mode.');
      return this.simulateDevPurchase(params.productId, params.purchaseToken, params.isSubscription ?? false);
    }

    try {
      if (params.isSubscription) {
        const res = await publisher.purchases.subscriptions.get({
          packageName: params.packageName,
          subscriptionId: params.productId,
          token: params.purchaseToken,
        });

        const isValid = res.data.paymentState === 1 || res.data.paymentState === 2; // 1: Received, 2: Free trial
        return {
          isValid,
          orderId: res.data.orderId ?? `SUB_${Date.now()}`,
          purchaseState: 0,
          productId: params.productId,
          purchaseToken: params.purchaseToken,
          grantedMinutes: 60,
          isSubscription: true,
          tier: params.productId.includes('annual') ? 'Annual VIP' : 'Monthly VIP',
          message: isValid ? 'Subscription verified successfully' : 'Subscription payment not completed',
        };
      } else {
        const res = await publisher.purchases.products.get({
          packageName: params.packageName,
          productId: params.productId,
          token: params.purchaseToken,
        });

        const isValid = res.data.purchaseState === 0; // 0: Purchased
        let grantedMinutes = 10;
        if (params.productId.includes('50')) grantedMinutes = 50;
        if (params.productId.includes('100')) grantedMinutes = 100;

        return {
          isValid,
          orderId: res.data.orderId ?? `ORD_${Date.now()}`,
          purchaseState: res.data.purchaseState ?? 0,
          consumptionState: res.data.consumptionState ?? 0,
          acknowledgementState: res.data.acknowledgementState ?? 0,
          productId: params.productId,
          purchaseToken: params.purchaseToken,
          grantedMinutes,
          isSubscription: false,
          message: isValid ? 'One-time product verified successfully' : 'Product purchase not valid',
        };
      }
    } catch (err: any) {
      console.error('Google Play verification error:', err?.message || err);
      return {
        isValid: false,
        productId: params.productId,
        purchaseToken: params.purchaseToken,
        grantedMinutes: 0,
        isSubscription: params.isSubscription ?? false,
        message: err?.message || 'Verification failed with Google Play API',
      };
    }
  }

  private static simulateDevPurchase(productId: string, purchaseToken: string, isSubscription: boolean): VerifyPurchaseResult {
    let grantedMinutes = 15;
    let tier = 'Trial';

    if (productId.includes('monthly')) {
      tier = 'Monthly VIP';
      grantedMinutes = 45;
    } else if (productId.includes('annual')) {
      tier = 'Annual VIP';
      grantedMinutes = 120;
    }

    return {
      isValid: true,
      orderId: `DEV_GPA.${Math.floor(1000 + Math.random() * 9000)}-${Math.floor(1000 + Math.random() * 9000)}`,
      purchaseState: 0,
      productId,
      purchaseToken,
      grantedMinutes,
      isSubscription,
      tier,
      message: 'Verified successfully in development environment',
    };
  }
}
