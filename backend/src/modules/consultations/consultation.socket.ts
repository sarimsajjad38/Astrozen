import { PrismaClient } from '@prisma/client';

interface MinimalWebSocket {
  on(event: string, listener: (...args: any[]) => void): this;
  send(data: string): void;
}

interface ActiveSession {
  consultationId: string;
  dbRecordId?: string;
  userId: string;
  expertId: string;
  expertName: string;
  socket: MinimalWebSocket;
  startedAt: number;
  durationSeconds: number;
  timer: NodeJS.Timeout | null;
}

export class ConsultationSocketHub {
  private static sessions = new Map<string, ActiveSession>();
  private static prisma = new PrismaClient();

  public static handleConnection(socket: MinimalWebSocket, req: any) {
    let currentSessionId: string | null = null;

    socket.on('message', async (raw: string) => {
      try {
        const payload = JSON.parse(raw.toString());

        switch (payload.event) {
          case 'join_consultation': {
            const { consultationId, userId, expertId, expertName } = payload.data;
            currentSessionId = consultationId;

            // Check user balance in Supabase
            let userMinutes = 5;
            let dbRecordId: string | undefined;

            if (userId) {
              const user = await this.prisma.user.findUnique({ where: { id: userId } });
              if (user) {
                userMinutes = user.walletMinutes;
                if (userMinutes <= 0) {
                  socket.send(
                    JSON.stringify({
                      event: 'insufficient_balance',
                      data: {
                        message: 'Aapka consultation balance samapt ho chuka hai. Kripya wallet recharge karein.',
                        walletMinutes: 0,
                      },
                    })
                  );
                  return;
                }

                // Create consultation row in Supabase
                const record = await this.prisma.consultation.create({
                  data: {
                    userId: user.id,
                    expertId: expertId || '1',
                    expertName: expertName || 'Acharya Suresh Kumar',
                    type: 'chat',
                    status: 'active',
                    ratePerMinute: 20.0,
                    durationSeconds: 0,
                  },
                });
                dbRecordId = record.id;
              }
            }

            const session: ActiveSession = {
              consultationId,
              dbRecordId,
              userId,
              expertId,
              expertName: expertName || 'Vedic Expert',
              socket,
              startedAt: Date.now(),
              durationSeconds: 0,
              timer: null,
            };

            // Set up 60-second billing cycle ticker
            session.timer = setInterval(async () => {
              session.durationSeconds += 60;
              const elapsedMins = Math.floor(session.durationSeconds / 60);

              let remainingMinutes = 0;

              // Deduct 1 minute in Supabase
              if (session.userId) {
                try {
                  const u = await this.prisma.user.findUnique({ where: { id: session.userId } });
                  if (u) {
                    const updatedMins = Math.max(0, u.walletMinutes - 1);
                    remainingMinutes = updatedMins;

                    await this.prisma.user.update({
                      where: { id: session.userId },
                      data: { walletMinutes: updatedMins },
                    });

                    await this.prisma.walletLedger.create({
                      data: {
                        userId: session.userId,
                        deltaMinutes: -1,
                        balanceAfter: updatedMins,
                        actionType: 'CONSULTATION_DEBIT',
                        referenceId: session.dbRecordId,
                        description: `Consultation with ${session.expertName} (-1 min)`,
                      },
                    });

                    if (updatedMins <= 0) {
                      socket.send(
                        JSON.stringify({
                          event: 'balance_exhausted',
                          data: {
                            message: 'Aapka balance samapt ho gaya hai. Session samapt kiya ja raha hai.',
                          },
                        })
                      );
                      this.endSession(consultationId);
                      return;
                    }
                  }
                } catch (e) {
                  console.error('Error ticking minute in Supabase:', e);
                }
              }

              socket.send(
                JSON.stringify({
                  event: 'billing_minute_tick',
                  data: {
                    consultationId,
                    elapsedMinutes: elapsedMins,
                    remainingMinutes,
                    costPerMinute: 20,
                  },
                })
              );
            }, 60000);

            this.sessions.set(consultationId, session);

            socket.send(
              JSON.stringify({
                event: 'joined_consultation',
                data: {
                  consultationId,
                  status: 'connected',
                  walletMinutes: userMinutes,
                  welcomeMessage: `Namaste! Aapka consultation ${session.expertName} ke sath shuru ho chuka hai.`,
                },
              })
            );
            break;
          }

          case 'send_message': {
            const { consultationId, text } = payload.data;
            socket.send(
              JSON.stringify({
                event: 'message_received',
                data: {
                  consultationId,
                  sender: 'expert',
                  text: `Pranam! Main aapka sandesh samajh gaya: "${text}". Graha sthiti ke anusar aapke liye auspicious upaay nirdharit kiye ja rahe hain.`,
                  timestamp: new Date().toISOString(),
                },
              })
            );
            break;
          }

          case 'leave_consultation': {
            if (currentSessionId) {
              this.endSession(currentSessionId);
            }
            break;
          }
        }
      } catch (err) {
        console.error('WebSocket message parsing error:', err);
      }
    });

    socket.on('close', () => {
      if (currentSessionId) {
        this.endSession(currentSessionId);
      }
    });
  }

  private static async endSession(consultationId: string) {
    const session = this.sessions.get(consultationId);
    if (session) {
      if (session.timer) clearInterval(session.timer);

      // Finalize consultation in Supabase
      if (session.dbRecordId) {
        try {
          const totalMins = Math.ceil(session.durationSeconds / 60);
          await this.prisma.consultation.update({
            where: { id: session.dbRecordId },
            data: {
              status: 'completed',
              durationSeconds: session.durationSeconds,
              totalCost: totalMins * 20.0,
              endedAt: new Date(),
            },
          });
        } catch (e) {
          console.error('Error closing consultation in Supabase:', e);
        }
      }

      this.sessions.delete(consultationId);
    }
  }
}
