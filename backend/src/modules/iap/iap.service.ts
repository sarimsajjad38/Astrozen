import { PrismaClient } from '@prisma/client';
import { GooglePlayValidator, VerifyPurchaseResult } from './google-play.validator.js';

export class IapService {
  private static prisma = new PrismaClient();

  public static async processAndRecordPurchase(params: {
    userId: string;
    packageName: string;
    productId: string;
    purchaseToken: string;
    isSubscription?: boolean;
  }): Promise<{ success: boolean; data: VerifyPurchaseResult; updatedUser?: any }> {
    // 1. Verify token with Google Play Validator
    const result = await GooglePlayValidator.verifyPurchase(params);

    if (!result.isValid) {
      return { success: false, data: result };
    }

    try {
      // 2. Fetch user
      const user = await this.prisma.user.findUnique({
        where: { id: params.userId },
      });

      if (!user) {
        return { success: true, data: result };
      }

      const newMinutes = user.walletMinutes + result.grantedMinutes;

      // 3. Persist IapPurchase record in Supabase
      await this.prisma.iapPurchase.upsert({
        where: { purchaseToken: params.purchaseToken },
        update: {
          purchaseState: 0,
          isAcknowledged: true,
        },
        create: {
          userId: user.id,
          packageName: params.packageName,
          productId: params.productId,
          purchaseToken: params.purchaseToken,
          orderId: result.orderId,
          purchaseState: 0,
          isAcknowledged: true,
        },
      });

      // 4. Update user subscription and wallet minutes
      const updatedUser = await this.prisma.user.update({
        where: { id: user.id },
        data: {
          walletMinutes: newMinutes,
          isSubscribed: result.isSubscription ? true : user.isSubscribed,
          subscriptionTier: result.isSubscription ? result.tier : user.subscriptionTier,
        },
      });

      // 5. Create audit ledger record
      await this.prisma.walletLedger.create({
        data: {
          userId: user.id,
          deltaMinutes: result.grantedMinutes,
          deltaCoins: 0,
          balanceAfter: newMinutes,
          actionType: 'IAP_RECHARGE',
          referenceId: result.orderId,
          description: `Google Play purchase verified: ${params.productId} (+${result.grantedMinutes} mins)`,
        },
      });

      return { success: true, data: result, updatedUser };
    } catch (err) {
      console.error('Error recording IAP purchase in Supabase:', err);
      return { success: true, data: result };
    }
  }
}
