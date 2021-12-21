// Protocol (use http for local network)
// LOCAL
// const String proto = "http";
const String proto = "https";

// DEV
// const String serverIP = '165.227.178.14';
// const String serverURL = 'thedogbarksthesong.ml';
// const String bucketName = 'song_barker_sequences';

// K9DEV
// const String serverIP = '159.89.38.51';
// const String serverURL = 'thedogbarksthesong.ml';
// const String bucketName = 'song_barker_sequences';

// JMF
// const String serverIP = 'http://10.0.0.187:3000/';
// const String serverURL = 'http://10.0.0.187:3000';
// const String bucketName = 'song_barker_sequences';

// PROD
const String serverIP = '68.183.113.8';
const String serverURL = 'k-9karaoke.com';
const String bucketName = 'k9karaoke-prod';

// ALL
const Map<String, dynamic> defaultFaceCoordinates = {
  "leftEye": [-0.15, 0.2],
  "rightEye": [0.15, 0.2],
  "mouth": [0.0, -0.15],
  "mouthLeft": [-0.1, -0.1],
  "mouthRight": [0.1, -0.1],
  "headTop": [0.0, 0.4],
  "headRight": [0.3, 0.0],
  "headBottom": [0.0, -0.4],
  "headLeft": [-0.3, 0.0],
};

const defaultMouthColor = [
  0.14901960784313725,
  0.10196078431372549,
  0.11372549019607843
];
const defaultLipColor = [
  0.2196078431372549,
  0.023529411764705882,
  0.023529411764705882
];
const defaultLipThickness = 0.2;

Map<String, String> displayNames = {
  "rightEye": "Right eye",
  "leftEye": "Left eye",
  "mouth": "Mouth center",
  "mouthRight": "Right mouth corner",
  "mouthLeft": "Left mouth corner",
  "headBottom": "Head bottom",
  "headRight": "Head right",
  "headLeft": "Head left",
  "headTop": "Head top",
};

String framesPath = "assets/card_frames/";

Map<String, String> songFamilyToCardFileName = {
  "ABC Song": 'abc1.png',
  "Auld Lang Syne": 'new-year-champagne.png',
  "Baby Shark": "baby-shark.png",
  "Dreidel Song": 'hanukkah-dreidel.png',
  "Happy Birthday (guitar)": 'birthday-dog.png',
  "Happy Birthday (oompah)": 'birthday-dog.png',
  "Happy Birthday (rock)": 'birthday-dog.png',
  "Happy Birthday (piano fast)": 'birthday-dog.png',
  "Happy Birthday (piano slow)": 'birthday-dog.png',
  "Happy Birthday (piano)": 'birthday-dog.png',
  "Hava Nagila": 'torah.png',
  "Jingle Bells": 'christmas-santa.png',
  "O Canada": "o-canada.png",
  "Old Macdonald": "farm.png",
  "Star Spangled Banner": "liberty-flag.png",
  "Take Me Out To The B'game": 'baseball.png',
  "That's Alright": "50s.png",
  "Twinkle Twinkle": "twinkle-star.png",
  "We Wish You A Merry X-Mas": "christmas-package.png",
  "Beethoven's 5th": "beethoven's_5th.png",
  "99 Bottles of Beer": "99.png",
  "La Cucaracha": "la-cucaracha.png",
};

Map<String, List<String>> get frameFileNames {
  return {
    "Birthday": [
      'no-frame',
      'birthday-bone.png',
      'birthday-dog.png',
      'birthday-4.png',
      'birthday-1.png',
      'birthday-2.png',
      'birthday-3.png',
      'birthday-package.png',
      'birthday-package-blue.png',
      'birthday-package-orange.png',
      'birthday-package-pink.png',
    ],
    "Greetings": [
      'congratulations.png',
      'get-well.png',
      'thinking-of-you-1.png',
      'thinking-of-you-2.png',
      'i-love-you.png',
      'hooray.png',
      'im-sorry-1.png',
      'im-sorry-2.png',
      'im-sorry-3.png',
      'im-sorry-4.png',
      'look-what-i-did.png',
      'good-luck.png',
      'hows-it-going-.png',
      'I-like-you.png',
      'i-miss-you-2.png',
      'i-miss-you.png',
      'thinking-of-you-3.png',
      'whats-up-.png',
      'you-got-this.png',
      "You're-OK!.png",
    ],
    "Christmas": [
      "christmas-package.png",
      'christmas-santa.png',
      'christmas-gifts.png',
      'christmas-ornaments.png',
      'christmas-wreath.png',
    ],
    "Jewish": [
      'hanukkah-dreidel.png',
      'hanukkah-dreidel2.png',
      'hanukkah-package.png',
      'kiddush-cup.png',
      'torah.png',
    ],
    "New Years": [
      'new-year-baby.png',
      'new-year-cat.png',
      'new-year-dog.png',
      'new-year-champagne.png',
      'new-year-fireworks.png',
    ],
    "Holidays": [
      'valentine.png',
      'easter.png',
      'mothers-day.png',
      'fathers-day.png',
      'halloween.png',
      'thanksgiving.png',
    ],
    "National": [
      'july-4th.png',
      'liberty-flag.png',
      'fireworks.png',
      'flag.png',
      'liberty.png',
      'liberty-flag-4th1.png',
      'flag-4th2.png',
      'o-canada.png',
    ],
    "Kids": [
      'abc1.png',
      'abc2.png',
      'baby-shark.png',
      'twinkle-star.png',
      'farm.png',
      'odor.png',
    ],
    "Misc": [
      "beethoven's_5th.png",
      '50s.png',
      'la-cucaracha.png',
      'beach.png',
      'dog-house.png',
      'flowers.png',
      'ocean.png',
      'space.png',
      'dog-day.png',
      '99.png',
      '99-2.png',
    ],
    "Sports": [
      'baseball.png',
      'basketball.png',
      'football.png',
      'hockey.png',
      'ski.png',
      'soccer.png',
    ],
    "Abstract": [
      'abstract-rainbow.png',
      'abstract-psychedelic.png',
      'abstract1.png',
      'abstract2.png',
      'abstract3.png',
      'abstract4.png',
    ],
    "Colors": [
      'color-black.png',
      'color-blue.png',
      'color-green.png',
      'color-orange.png',
      'color-pink.png',
      'color-purple.png',
      'color-red.png',
      'color-white.png',
    ],
  };
}
