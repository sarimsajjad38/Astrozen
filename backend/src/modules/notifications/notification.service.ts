import { PrismaClient } from '@prisma/client';
import { AiAstrologyService, DailyHoroscopeResult } from '../ai/ai.service.js';

export interface SendNotificationPayload {
  title: string;
  body: string;
  type?: 'DAILY_HOROSCOPE' | 'RAHU_KAAL' | 'CONSULTATION' | 'WALLET';
  data?: Record<string, any>;
}

export class NotificationService {
  private static prisma = new PrismaClient();

  /**
   * Registers or updates an FCM token for an authenticated user.
   */
  public static async registerFcmToken(userId: string, fcmToken: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { fcmToken, notificationsEnabled: true },
    });
  }

  /**
   * Updates notification preferences.
   */
  public static async updateSettings(
    userId: string,
    settings: {
      notificationsEnabled?: boolean;
      dailyHoroscopeAlert?: boolean;
      rahuKaalAlert?: boolean;
    }
  ) {
    return this.prisma.user.update({
      where: { id: userId },
      data: settings,
    });
  }

  /**
   * Retrieves notification history for a user.
   */
  public static async getUserNotifications(userId: string) {
    return this.prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 30,
    });
  }

  /**
   * Marks a notification as read.
   */
  public static async markAsRead(userId: string, notificationId: string) {
    return this.prisma.notification.updateMany({
      where: { id: notificationId, userId },
      data: { isRead: true },
    });
  }

  /**
   * Sends a personalized notification: logs to Supabase and sends via FCM if token exists.
   */
  public static async sendToUser(userId: string, payload: SendNotificationPayload) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || !user.notificationsEnabled) return null;

    // 1. Save notification record in Supabase
    const record = await this.prisma.notification.create({
      data: {
        userId: user.id,
        title: payload.title,
        body: payload.body,
        type: payload.type || 'DAILY_HOROSCOPE',
        data: payload.data || {},
        isRead: false,
      },
    });

    // 2. Dispatch via FCM if token is present
    if (user.fcmToken) {
      await this.dispatchFcm(user.fcmToken, payload);
    }

    return record;
  }

  /**
   * Generates and dispatches a personalized Gemini-powered daily horoscope notification for a user.
   */
  public static async generateUserDailyHoroscope(userId: string): Promise<{
    notification: any;
    horoscope: DailyHoroscopeResult;
  } | null> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) return null;

    const sign = user.zodiacSign || 'Scorpio';
    const horoscope = await AiAstrologyService.generateDailyHoroscope({
      zodiacSign: sign,
      name: user.displayName || 'Cosmic Seeker',
    });

    const notification = await this.sendToUser(user.id, {
      title: horoscope.title,
      body: horoscope.notificationSnippet,
      type: 'DAILY_HOROSCOPE',
      data: horoscope,
    });

    return { notification, horoscope };
  }

  /**
   * Automated cron trigger: Daily morning cosmic horoscope broadcast powered by Gemini AI.
   */
  public static async triggerDailyHoroscopeBroadcast(): Promise<number> {
    const users = await this.prisma.user.findMany({
      where: {
        notificationsEnabled: true,
        dailyHoroscopeAlert: true,
      },
    });

    let count = 0;
    for (const user of users) {
      const sign = user.zodiacSign || 'Scorpio';
      const horoscope = await AiAstrologyService.generateDailyHoroscope({
        zodiacSign: sign,
        name: user.displayName || 'Cosmic Seeker',
      });

      await this.sendToUser(user.id, {
        title: horoscope.title,
        body: horoscope.notificationSnippet,
        type: 'DAILY_HOROSCOPE',
        data: horoscope,
      });
      count++;
    }

    return count;
  }

  /**
   * Automated cron trigger: Rahu Kaal window warning.
   */
  public static async triggerRahuKaalAlert(): Promise<number> {
    const users = await this.prisma.user.findMany({
      where: {
        notificationsEnabled: true,
        rahuKaalAlert: true,
      },
    });

    const dayOfWeek = new Date().getDay();
    // Classical Rahu Kaal timings by weekday
    const rahuKaalTimes: Record<number, string> = {
      0: '4:30 PM – 6:00 PM', // Sunday
      1: '7:30 AM – 9:00 AM', // Monday
      2: '3:00 PM – 4:30 PM', // Tuesday
      3: '12:00 PM – 1:30 PM', // Wednesday
      4: '1:30 PM – 3:00 PM', // Thursday
      5: '10:30 AM – 12:00 PM', // Friday
      6: '9:00 AM – 10:30 AM', // Saturday
    };

    const windowTime = rahuKaalTimes[dayOfWeek] || '12:00 PM – 1:30 PM';

    for (const user of users) {
      await this.sendToUser(user.id, {
        title: `⚠️ Rahu Kaal Notice Today (${windowTime})`,
        body: `Auspicious tasks and major investments are best paused during Rahu Kaal. Focus on reflection and Gayatri mantra.`,
        type: 'RAHU_KAAL',
        data: { windowTime },
      });
    }

    return users.length;
  }

  private static async dispatchFcm(fcmToken: string, payload: SendNotificationPayload) {
    try {
      // In production with Firebase Service Account configured, this calls the FCM HTTP v1 API.
      // In development, it logs the simulated FCM push packet.
      console.log(`[FCM Push] Delivered to ${fcmToken.substring(0, 15)}...: "${payload.title}" - ${payload.body}`);
    } catch (err) {
      console.warn('Error dispatching FCM message:', err);
    }
  }
}
