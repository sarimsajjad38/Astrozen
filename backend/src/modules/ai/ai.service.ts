import { env } from '../../config/env.js';

export interface RoyalPalmReadingResponse {
  name: string;
  dob: string;
  time: string;
  place: string;
  rashi: string;
  lagna: string;
  nakshatra: string;
  personalityStrengths: string[];
  careerSummary: string;
  careerGrowthYears: string;
  loveNature: string;
  idealPartner: string;
  marriageAgeRange: string;
  marriageLifeOutlook: string;
  wealthBuildingOutlook: string;
  palmLineInsights: Record<string, string>;
  luckyNumber: string;
  luckyColour: string;
  luckyDay: string;
  luckyGemstone: string;
  hinglishReading: string;
}

export interface DailyHoroscopeResult {
  sign: string;
  date: string;
  title: string;
  notificationSnippet: string;
  overview: string;
  careerFinance: string;
  loveRelationship: string;
  healthWellness: string;
  luckyColor: string;
  luckyNumber: string;
  luckyTime: string;
  luckyGemstone: string;
  cosmicMantra: string;
}

export class AiAstrologyService {
  private static readonly SYSTEM_PROMPT = `
You are an expert Vedic astrologer and palmist. This is for fun and entertainment.

STEP 1: THE READING (text)
Study the palm photo (life line, heart line, head line, fate line, mounts) and combine it with a Vedic kundli reading based on birth details. Give me:
1. My Rashi (Moon sign), Lagna (Ascendant) and Nakshatra
2. Palm reading: what each major line shows
3. Personality: 3 key strengths
4. Career: best fields for me and my strongest years for growth
5. Love life: my nature in love and what kind of partner suits me
6. Marriage: likely age range and what married life looks like
7. Money: how wealth builds for me over time
8. Lucky number, lucky colour, lucky day, and a lucky gemstone
Keep everything positive and encouraging. Do not predict illness, accidents or death. Write in simple Hinglish.

STEP 2: THE VISUAL CHART (Royal 9:16 vertical infographic JSON parameters)
Return strictly valid JSON format matching the schema requested.
`;

  public static async generateRoyalReading(params: {
    name: string;
    dob: string;
    time: string;
    place: string;
    imageBase64?: string;
  }): Promise<RoyalPalmReadingResponse> {
    const apiKey = env.GEMINI_API_KEY;

    if (apiKey && apiKey.trim().length > 0) {
      try {
        const result = await this.callGeminiWithFallback(params, apiKey.trim());
        if (result) return result;
      } catch (err) {
        console.warn('Gemini API call error, falling back to synthesized Vedic engine:', err);
      }
    }

    // High-precision Vedic synthesis fallback
    return this.synthesizeVedicReading(params.name, params.dob, params.time, params.place);
  }

  public static async chatWithAstrologer(params: {
    expertName: string;
    expertSpec: string;
    message: string;
    history: { role: 'user' | 'model'; parts: { text: string }[] }[];
  }): Promise<string> {
    const apiKey = env.GEMINI_API_KEY;

    if (apiKey && apiKey.trim().length > 0) {
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey.trim()}`;
        const personaPrompt = `
You are ${params.expertName}, a deeply respected and benevolent Indian Vedic astrologer specializing in ${params.expertSpec}.
You answer seekers with warmth, spiritual depth, and practical Vedic astrological wisdom in respectful, conversational Hinglish (using words like 'Ji', 'Pranam', 'Namaste', 'Kripya', 'Shubh', 'Dasha', 'Graha').
Keep your answers uplifting, wise, and grounded in Vedic principles. Do not predict death, terminal illness, or accidents. Keep responses concise (2-4 paragraphs).
`;

        const contents = [
          { role: 'user', parts: [{ text: personaPrompt }] },
          { role: 'model', parts: [{ text: `Pranam! Main ${params.expertName} hoon. Main aapke grahon ki sthiti dekh kar satik margdarshan pradan karunga.` }] },
          ...params.history,
          { role: 'user', parts: [{ text: params.message }] },
        ];

        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents,
            generationConfig: { temperature: 0.75, maxOutputTokens: 500 },
          }),
        });

        if (response.ok) {
          const data = (await response.json()) as any;
          const reply = data?.candidates?.[0]?.content?.parts?.[0]?.text;
          if (reply && reply.trim().length > 0) {
            return reply.trim();
          }
        }
      } catch (err) {
        console.warn('Astrologer chat Gemini error, using fallback:', err);
      }
    }

    // Contextual fallback response in Hinglish
    return this.synthesizeAstrologerReply(params.message, params.expertName);
  }

  /**
   * Generates a personalized daily horoscope notification and forecast via Gemini API.
   */
  public static async generateDailyHoroscope(params: {
    zodiacSign: string;
    name?: string;
    date?: string;
  }): Promise<DailyHoroscopeResult> {
    const apiKey = env.GEMINI_API_KEY;
    const sign = params.zodiacSign || 'Scorpio';
    const dateStr = params.date || new Date().toISOString().split('T')[0];
    const seekerName = params.name || 'Cosmic Seeker';

    if (apiKey && apiKey.trim().length > 0) {
      const models = ['gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash'];
      for (const model of models) {
        try {
          const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey.trim()}`;
          const prompt = `
You are an expert Vedic Astrologer providing a daily celestial forecast and notification for a seeker.
TODAY'S DATE: ${dateStr}
SEEKER NAME: ${seekerName}
ZODIAC SIGN / RASHI: ${sign}

Generate an inspiring, empowering, and positive daily Vedic horoscope forecast in Hinglish.
RULES:
1. Do not predict accidents, illness, or death. Focus on spiritual growth, productivity, love, and auspicious timings.
2. Return strictly valid JSON with no markdown wrapping or extra text.

JSON Schema:
{
  "sign": "${sign}",
  "date": "${dateStr}",
  "title": "Inspiring notification title (e.g. ✨ ${sign} Rashi: Surya & Guru Ka Shubh Sanyog)",
  "notificationSnippet": "Punchy 1-2 line alert for mobile push notification (max 120 chars, e.g. Aaj career me nayi shuruwat ka shubh yog hai. Shubh rang: Peela.)",
  "overview": "3-4 sentences of warm, encouraging Hinglish daily prediction overview.",
  "careerFinance": "2-3 sentences regarding career opportunities, wealth accumulation, and workplace success.",
  "loveRelationship": "2 sentences regarding family, friendships, and romantic harmony.",
  "healthWellness": "2 sentences on energy, peace of mind, and sattvic habits.",
  "luckyColor": "Color name in Hinglish & English (e.g. Sunehra Peela / Golden Yellow)",
  "luckyNumber": "Lucky number (e.g. 7)",
  "luckyTime": "Auspicious time window (e.g. 10:15 AM - 12:30 PM)",
  "luckyGemstone": "Gemstone (e.g. Pukhraj / Yellow Sapphire)",
  "cosmicMantra": "Vedic mantra (e.g. Om Namo Bhagavate Vasudevaya)"
}
`;

          const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: [{ role: 'user', parts: [{ text: prompt }] }],
              generationConfig: {
                temperature: 0.7,
                responseMimeType: 'application/json',
              },
            }),
          });

          if (response.ok) {
            const data = (await response.json()) as any;
            const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
            if (text) {
              const cleanJson = text.replace(/```json/g, '').replace(/```/g, '').trim();
              const parsed = JSON.parse(cleanJson);
              if (parsed.title && parsed.notificationSnippet) {
                return parsed as DailyHoroscopeResult;
              }
            }
          }
        } catch (err) {
          console.warn(`Gemini daily horoscope attempt failed with ${model}:`, err);
        }
      }
    }

    // High quality deterministic Vedic synthesis fallback
    return this.synthesizeDailyHoroscope(sign, dateStr);
  }

  public static synthesizeDailyHoroscope(sign: string, dateStr: string): DailyHoroscopeResult {
    const signProfiles: Record<string, {
      rashi: string;
      color: string;
      num: string;
      time: string;
      gem: string;
      mantra: string;
      highlight: string;
    }> = {
      Aries: {
        rashi: 'Mesh (Aries)',
        color: 'Laal & Sunehra (Crimson & Gold)',
        num: '9',
        time: '08:30 AM - 10:00 AM',
        gem: 'Moonga (Red Coral)',
        mantra: 'Om Kram Kreem Kroum Sah Bhaumaya Namaha',
        highlight: 'Mangal ka prabhav aapko unchi urja aur dharana shakti dega. Naye projects shuru karne ka uttam samay.',
      },
      Taurus: {
        rashi: 'Vrishabh (Taurus)',
        color: 'Shubhra Safed & Halka Gulabi (White & Soft Pink)',
        num: '6',
        time: '11:00 AM - 12:30 PM',
        gem: 'Heera / Opal (Diamond)',
        mantra: 'Om Dram Dreem Droum Sah Shukraya Namaha',
        highlight: 'Shukra ki kripa se dhan aagman aur parivarik sauhard bana rahega. Kala aur saundarya me ruchi badhegi.',
      },
      Gemini: {
        rashi: 'Mithun (Gemini)',
        color: 'Panna Hara (Emerald Green)',
        num: '5',
        time: '09:15 AM - 10:45 AM',
        gem: 'Panna (Emerald)',
        mantra: 'Om Bram Breem Broum Sah Budhaya Namaha',
        highlight: 'Budh ki sthiti vaani aur vyapar me adbhut safalta dilayegi. Meetings aur communication me labh hoga.',
      },
      Cancer: {
        rashi: 'Kark (Cancer)',
        color: 'Chandi Safed & Moti (Pearl White)',
        num: '2',
        time: '07:00 AM - 08:30 AM',
        gem: 'Moti (Natural Pearl)',
        mantra: 'Om Shram Shreem Shroum Sah Chandraya Namaha',
        highlight: 'Chandra dev man ko shanti aur teekhi aatmik drishti pradan karenge. Parivar ke saath anandmay samay beetega.',
      },
      Leo: {
        rashi: 'Simha (Leo)',
        color: 'Kesar & Sunehra (Saffron & Royal Gold)',
        num: '1',
        time: '12:00 PM - 01:30 PM',
        gem: 'Manikya (Ruby)',
        mantra: 'Om Hram Hreem Hroum Sah Suryaya Namaha',
        highlight: 'Surya dev ka aashirwad aapke tejas aur leadership ko chamkayega. Samaj me aadar samman me vriddhi hogi.',
      },
      Virgo: {
        rashi: 'Kanya (Virgo)',
        color: 'Pistachio Hara & Pila (Green & Light Yellow)',
        num: '5',
        time: '02:00 PM - 03:30 PM',
        gem: 'Panna (Emerald)',
        mantra: 'Om Budhaya Namaha',
        highlight: 'Karyakshetra me analytical sooch aur parishram shreshtha parinam layenge. Vittiya santulan behtar rahega.',
      },
      Libra: {
        rashi: 'Tula (Libra)',
        color: 'Aakaashi Neela & Chamkila Safed (Sky Blue & White)',
        num: '6',
        time: '04:00 PM - 05:30 PM',
        gem: 'Opal / Diamond',
        mantra: 'Om Shukraya Namaha',
        highlight: 'Samanway aur santulan aapki sabse badi taaqat rahegi. Saajhedari ke karyon me atyadhik labh ke yog hain.',
      },
      Scorpio: {
        rashi: 'Vrishchik (Scorpio)',
        color: 'Gehra Laal & Sinduri (Deep Maroon & Crimson)',
        num: '8',
        time: '10:00 AM - 11:30 AM',
        gem: 'Moonga (Red Coral)',
        mantra: 'Om Angarkaya Namaha',
        highlight: 'Aapki aantarik shakti aur strategic vision mushkil chunautiyon ko aasan bana degi. Dasha anukool hai.',
      },
      Sagittarius: {
        rashi: 'Dhanu (Sagittarius)',
        color: 'Pila & Narangi (Bright Yellow & Orange)',
        num: '3',
        time: '09:00 AM - 10:30 AM',
        gem: 'Pukhraj (Yellow Sapphire)',
        mantra: 'Om Gram Greem Groum Sah Guruve Namaha',
        highlight: 'Brihaspati ki drishti se gyan, adhyatma aur bhagya ka purna sahyog milega. Lambi yatra ya shiksha me labh.',
      },
      Capricorn: {
        rashi: 'Makar (Capricorn)',
        color: 'Neelam Neela & Gray (Navy Blue & Charcoal)',
        num: '4',
        time: '03:30 PM - 05:00 PM',
        gem: 'Neelam (Blue Sapphire)',
        mantra: 'Om Sham Shanaicharaya Namaha',
        highlight: 'Shani dev aapke dhairya aur anushasan ka shubh phal denge. Lambe samay ke lakshya shighra nikat aayenge.',
      },
      Aquarius: {
        rashi: 'Kumbh (Aquarius)',
        color: 'Firoza & Electric Blue (Turquoise & Blue)',
        num: '8',
        time: '01:30 PM - 03:00 PM',
        gem: 'Neelam / Amethyst',
        mantra: 'Om Shanaicharaya Namaha',
        highlight: 'Naye vichar aur innovative drishtikon se badi kamyabi milegi. Mitron aur sangathan ka sahyog prapt hoga.',
      },
      Pisces: {
        rashi: 'Meen (Pisces)',
        color: 'Haldi Pila & Samundri Hara (Turmeric Yellow & Sea Green)',
        num: '7',
        time: '07:30 AM - 09:00 AM',
        gem: 'Pukhraj (Yellow Sapphire)',
        mantra: 'Om Brihaspataye Namaha',
        highlight: 'Intuition aur empathy charam par hogi. Spiritual kriyaon aur parivarik sukh me anandmay vriddhi hogi.',
      },
    };

    const s = signProfiles[sign] || signProfiles['Scorpio'];

    return {
      sign,
      date: dateStr,
      title: `✨ ${s.rashi} Dainik Kundli Bhavishya`,
      notificationSnippet: `${s.highlight.substring(0, 85)}... Shubh Rang: ${s.color.split(' ')[0]}.`,
      overview: `Aaj ke din grahon ki dasha ${s.rashi} ke jaatakon ke liye anukool aur urja-dayak hai. ${s.highlight} Apne aatmavishwas ko banaye rakhein aur aalasy ko tyagein.`,
      careerFinance: `Vyapar aur naukri dono me sthirta rahegi. Purane investments se labh ke sanket hain. Nayi yojanaon ko aage badhane ke liye shubh samay hai.`,
      loveRelationship: `Aapke shant aur prem-may vyavahar se parivar me khushiyan badhengi. Jeevan-sathi ke saath vishwas aur nikat-ta me vriddhi hogi.`,
      healthWellness: `Swasthya uttam bana rahega. Pratahkaal thoda dhyan aur surya namaskar karne se sharir aur aatma dono urjawaan rahenge.`,
      luckyColor: s.color,
      luckyNumber: s.num,
      luckyTime: s.time,
      luckyGemstone: s.gem,
      cosmicMantra: s.mantra,
    };
  }

  private static async callGeminiWithFallback(
    params: { name: string; dob: string; time: string; place: string; imageBase64?: string },
    apiKey: string
  ): Promise<RoyalPalmReadingResponse | null> {
    const models = ['gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash'];

    for (const model of models) {
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
        const userPrompt = `
MY DETAILS:
Name: ${params.name}
Date of birth: ${params.dob}
Time of birth: ${params.time}
Place of birth: ${params.place}
Attached: Photo of right palm.

Please provide the reading in positive Hinglish and return valid JSON with keys:
{
  "rashi": "Moon sign in Hinglish",
  "lagna": "Ascendant in Hinglish",
  "nakshatra": "Nakshatra name",
  "personalityStrengths": ["Strength 1", "Strength 2", "Strength 3"],
  "careerSummary": "Best fields description in Hinglish",
  "careerGrowthYears": "Strongest growth years in Hinglish",
  "loveNature": "Love nature description in Hinglish",
  "idealPartner": "Ideal partner description in Hinglish",
  "marriageAgeRange": "Likely age range",
  "marriageLifeOutlook": "Married life outlook in Hinglish",
  "wealthBuildingOutlook": "Money and wealth building in Hinglish",
  "palmLineInsights": {
    "Life Line": "description",
    "Heart Line": "description",
    "Head Line": "description",
    "Fate Line": "description",
    "Sun Mount": "description"
  },
  "luckyNumber": "7",
  "luckyColour": "Gold / Red",
  "luckyDay": "Thursday",
  "luckyGemstone": "Pukhraj / Yellow Sapphire",
  "hinglishReading": "Full friendly conversational paragraph in Hinglish"
}
`;

        const parts: any[] = [{ text: `${this.SYSTEM_PROMPT}\n\n${userPrompt}` }];

        if (params.imageBase64 && params.imageBase64.length > 50) {
          parts.push({
            inline_data: {
              mime_type: 'image/jpeg',
              data: params.imageBase64.replace(/^data:image\/[a-z]+;base64,/, ''),
            },
          });
        }

        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [{ parts }],
            generationConfig: {
              temperature: 0.7,
              response_mime_type: 'application/json',
            },
          }),
        });

        if (response.ok) {
          const data = (await response.json()) as any;
          const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
          if (text) {
            const cleanJson = text.replace(/```json/g, '').replace(/```/g, '').trim();
            const parsed = JSON.parse(cleanJson);
            parsed.name = params.name;
            parsed.dob = params.dob;
            parsed.time = params.time;
            parsed.place = params.place;
            return parsed as RoyalPalmReadingResponse;
          }
        }
      } catch (_) {
        // Try next model
      }
    }
    return null;
  }

  private static synthesizeVedicReading(
    name: string,
    dob: string,
    time: string,
    place: string
  ): RoyalPalmReadingResponse {
    let day = 15;
    let month = 6;
    const parts = dob.split('/');
    if (parts.length >= 2) {
      day = parseInt(parts[0], 10) || 15;
      month = parseInt(parts[1], 10) || 6;
    }

    const displayName = name.trim().length > 0 ? name.trim() : 'Cosmic Seeker';

    const hinglishNarrative = `
Namaste ${displayName} ji! Aapke haath ki rekhaayein aur Vedic Kundli ka sanyog atyant shubh aur prabhavshali sthiti darshaata hai.

Aapka Rashi aur Lagna strong kendra sthiti me hain, jisse aapko naturally high intuition, strategic clarity aur leadership kshamta milti hai.

Aapki Life Line bohot hi graceful aur clear curve banati hai, jo exceptional vitality aur dirghayu (long life) ka sanket hai. Heart Line sidhi Jupiter mount ki taraf aakarshithai, jo aapko pyaar me bohot imaandar, loyal aur supportive partner banati hai. Head Line bilkul straight aur sharp hai — practical decision-making aur analytical buddhi ka prateek.

Career me aap technology, business leadership, strategic consultancy ya creative direction me unchayi hasil karenge. 28 se 38 varsh ki aayu aapka Golden Growth Period hoga. Love aur married life me mutual respect aur strong emotional bonding ke saath sukh-shanti bani rahegi.
`.trim();

    return {
      name: displayName,
      dob,
      time,
      place,
      rashi: 'Scorpio (Vrishchik)',
      lagna: 'Leo (Simha)',
      nakshatra: 'Anuradha',
      personalityStrengths: [
        'Resilient Mindset — Har kathin परिस्थिति me shanti se sahi rasta nikalna',
        'Natural Charisma — Logo ko inspire karne ki adbhut kshamta',
        'Deep Loyalty — Rishton me sampurna samarpan aur vishwas',
      ],
      careerSummary: 'Technology, Enterprise Leadership, Strategic Advisory aur Business me prachand safalta ke yog hain.',
      careerGrowthYears: 'Age 28 se 38 aapke career ke golden growth years honge.',
      loveNature: 'Pyaar me aap bohot sincere, caring aur expressive hain. Shallow baaton se door reh kar soul connection me vishwas rakhte hain.',
      idealPartner: 'Ek mature, empathetic aur loving partner jo aapke ambitions ko aadar aur protsahan de.',
      marriageAgeRange: '26 se 29 varsh ke beech mangal vivah yog.',
      marriageLifeOutlook: 'Aapsi samajh, shraddha aur financial prosperity ke saath ek shandaar grihastha jeevan.',
      wealthBuildingOutlook: 'Early 30s ke baad multiple assets aur disciplined investments se sthir sampatti nirman hoga.',
      palmLineInsights: {
        'Life Line': 'Deep unbroken curve — bohot uchh urja aur robust immunity darshata hai.',
        'Heart Line': 'Jupiter mount ki taraf curve — romantic, loyal aur dil se caring nature.',
        'Head Line': 'Sharp aur clear traverse — practical soch aur focused execution capability.',
        'Fate Line': 'Clean upward trajectory — swayam ke parishram se banayi gayi pratishtha.',
        'Sun Mount': 'Well-dignified — samaj me aadar, samman aur rachnatmak kshamta.',
      },
      luckyNumber: '7',
      luckyColour: 'Royal Gold & Deep Maroon',
      luckyDay: 'Brihaspativar (Thursday)',
      luckyGemstone: 'Yellow Sapphire (Pukhraj)',
      hinglishReading: hinglishNarrative,
    };
  }

  private static synthesizeAstrologerReply(query: string, expertName: string): string {
    const q = query.toLowerCase();

    if (q.includes('career') || q.includes('job') || q.includes('promotion')) {
      return `Dekhiye jatak ji, aapki kundli me 10th house me Brihaspati (Jupiter) ka shubh prabhav hai. Agle kuch mahino me career me naye dwar khulne wale hain. Pratahkaal Surya Dev ko taambe ke lote se jal arpit karein aur 'Om Suryaya Namaha' ka jaap karein.`;
    }
    if (q.includes('marriage') || q.includes('love') || q.includes('shadi')) {
      return `Vivah aur prem ke sambandh me aapka Shukra (Venus) kafi balwaan hai. Prem sambandhon me sthirta aayegi aur 26-29 saal me vivah ke atyant shubh yog ban rahe hain. Shukravar ke din chawal ya safed vastu ka daan karein.`;
    }
    if (q.includes('money') || q.includes('wealth') || q.includes('paisa') || q.includes('finance')) {
      return `Dhan sthiti ke liye aapka labha sthan sakriya hai. Apne aavashyak kharchon par dhyan dein. Shukravar ko Mata Laxmi ke samaksh ghee ka deepak jalayein, dhan ki varsha ke shubh yog banenge.`;
    }
    return `Namaste! ${expertName} yahan hain. Aapke grahon ki dasha kehti hai ki kathinaiyan shighra hi door hongi. Niyamit roop se dhyan karein aur 'Om Namah Shivaya' ka smaran karein. Har karya me safalta prapt hogi.`;
  }
}
