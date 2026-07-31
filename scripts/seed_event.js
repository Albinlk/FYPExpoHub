/**
 * seed_event.js
 * Creates the published `events/fskm-fyp-2026` document so public reads succeed.
 *
 * Usage: node scripts/seed_event.js
 */
const { EVENT_ID } = require('./lib/config');
const { getAccessToken, setDoc } = require('./lib/firebase_api');

async function main() {
  console.log('=== Seed Event Document ===\n');
  const token = await getAccessToken();

  const now = new Date();
  const event = {
    id: EVENT_ID,
    title: 'FSKM FYP Expo Hub 2026',
    sessionLabel: 'Semester March - August 2026',
    startAt: new Date(2026, 7, 6, 9, 0).toISOString(),
    endAt: new Date(2026, 7, 7, 17, 0).toISOString(),
    dailyHours: '9:00 AM - 5:00 PM',
    venue: 'Lecture Block, FSKM',
    locationDetails:
      'Seminar Hall & Lecture Rooms, Faculty of Computer and Mathematical Sciences (FSKM)',
    mapUrl: 'https://maps.google.com/?q=FSKM+UiTM',
    description:
      'The Final Year Project Exhibition (FYP Expo) FSKM is a bi-annual event showcasing the dedication, innovation, and technical expertise developed by final-semester students of the Faculty of Computer and Mathematical Sciences (FSKM). This exhibition serves as a vital bridge connecting academic research with industry partners.',
    objectives: [
      'Showcase the creativity and system design innovations of FSKM students.',
      'Provide a professional platform for presenting and defending project research outcomes.',
      'Foster strong collaboration networks among students, faculty, and industry leaders.',
      'Recognize outstanding achievements through best project award categories.',
    ],
    status: 'active',
    heroImageUrl: 'assets/images/banner.jpg',
    posterUrl: 'assets/images/poster.jpg',
    publicContactEmail: 'fskmfypexpo@uitm.edu.my',
    faqItems: [
      {
        question: 'What is FYP Expo Hub?',
        answer:
          'It is the official web portal for the Final Year Project Exhibition of the Faculty of Computer and Mathematical Sciences (FSKM).',
      },
      {
        question: 'Who can attend the exhibition?',
        answer:
          'The exhibition is open to all UiTM students, faculty members, and external industry visitors who are interested in final year student innovations.',
      },
      {
        question: 'Are there awards given to the projects?',
        answer:
          'Projects are evaluated by a panel of industry and academic juries, and awards like Gold, Silver, Bronze, and Best Innovative Project are presented.',
      },
    ],
    publicationStatus: 'published',
    updatedAt: now.toISOString(),
    publishedAt: now.toISOString(),
  };

  const res = await setDoc('events', EVENT_ID, event, token);
  if (res.status >= 200 && res.status < 300) {
    console.log(`Created/Updated events/${EVENT_ID} with publicationStatus=publish`);
  } else {
    console.error(`Failed (${res.status}):`, JSON.stringify(res.body).slice(0, 500));
    process.exit(1);
  }
}

main().catch(console.error);
