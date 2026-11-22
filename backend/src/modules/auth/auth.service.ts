import { PrismaClient } from '@prisma/client';

export class AuthService {
  private static prisma = new PrismaClient();

  public static async getOrCreateUser(params: {
    identifier?: string;
    displayName?: string;
    zodiacSign?: string;
  }) {
    const email = params.identifier?.includes('@') ? params.identifier : undefined;
    const phone = !params.identifier?.includes('@') && params.identifier ? params.identifier : undefined;

    // Check if user already exists
    if (email) {
      const existing = await this.prisma.user.findFirst({ where: { email } });
      if (existing) return existing;
    } else if (phone) {
      const existing = await this.prisma.user.findFirst({ where: { phone } });
      if (existing) return existing;
    }

    // Create a new user with 5 complimentary consultation minutes
    return this.prisma.user.create({
      data: {
        email,
        phone,
        displayName: params.displayName || 'Cosmic Seeker',
        zodiacSign: params.zodiacSign || 'Scorpio',
        walletMinutes: 5,
        walletCoins: 0.0,
        isSubscribed: false,
        subscriptionTier: 'Free',
      },
    });
  }

  public static async getUserProfile(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        kundliProfiles: {
          orderBy: { createdAt: 'desc' },
          take: 5,
        },
        consultations: {
          orderBy: { startedAt: 'desc' },
          take: 5,
        },
      },
    });
  }

  public static async updateUserProfile(
    userId: string,
    data: { displayName?: string; zodiacSign?: string }
  ) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        displayName: data.displayName,
        zodiacSign: data.zodiacSign,
      },
    });
  }
}
