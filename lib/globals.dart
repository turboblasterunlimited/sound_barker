// DEV
// const String serverIP = '165.227.178.14';
// const String serverURL = 'thedogbarksthesong.ml';
// const String bucketName = 'song_barker_sequences';

// PROD
const String serverIP = '68.183.113.8';
const String serverURL = 'k-9karaoke.com';
const String bucketName = 'k9karaoke-prod';

// ALL
const Map<String, dynamic> defaultFaceCoordinates = {
  "leftEye": [-0.15, 0.2],
  "rightEye": [0.15, 0.2],
  "mouth": [0.0, 0.0],
  "mouthLeft": [-0.1, 0.0],
  "mouthRight": [0.1, 0.0],
  "headTop": [0.0, 0.4],
  "headRight": [0.3, 0.0],
  "headBottom": [0.0, -0.4],
  "headLeft": [-0.3, 0.0],
};

Map<String, String> displayNames = {
  "rightEye": "Right Eye",
  "leftEye": "Left Eye",
  "mouth": "Mouth Center",
  "mouthRight": "Right Mouth",
  "mouthLeft": "Left Mouth",
  "headBottom": "Chin",
  "headRight": "Head Right",
  "headLeft": "Head Left",
  "headTop": "Head Top",
};

String framesPath = "assets/card_frames/";

Map<String, String> songFamilyToCardFileName = {
  "ABC Song": 'abc1.png',
  "Auld Lang Syne": 'new-year-champagne.png',
  "Baby Shark": "baby-shark.png",
  "Dreidel Song": 'hanukkah-dreidel.png',
  "Happy Birthday (guitar)": 'birthday-bone.png',
  "Happy Birthday (oompah)": 'birthday-bone.png',
  "Happy Birthday (rock)": 'birthday-bone.png',
  "Hava Nagila": 'torah.png',
  "Jingle Bells": 'christmas-santa.png',
  "O Canada": "o-canada.png",
  "Old Macdonald": "farm.png",
  "Star Spangled Banner": "liberty-flag.png",
  "Take Me Out To The Ball Game": 'baseball.png',
  "That's Alright": "50's.png",
  "Twinkle Twinkle": "twinkle-star.png",
  "We Wish You A Merry X-Mas": 'christmas-wreath.png',
  "Beethoven's 5th": "beethoven's_5th.png",
  "99 Bottles of Beer": "99.png",
  "La Cucaracha": "la-cucaracha.png",
};

Map<String, List<String>> get frameFileNames {
  return {
    "Birthday": [
      'no-frame',
      'birthday-bone.png',
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
      'july-4th.png',
      'thanksgiving.png',
      'halloween.png',
      'easter.png',
      'fathers-day.png',
      'mothers-day.png',
      'valentine.png',
    ],
    "National": [
      'o-canada.png',
      'liberty-flag.png',
      'fireworks.png',
      'flag.png',
      'liberty.png',
      'liberty-flag-4th1.png',
      'flag-4th2.png',
      'la-cucaracha.png'
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
      'abstract1.png',
      'abstract2.png',
      'abstract3.png',
      'abstract4.png',
      'abstract-rainbow.png',
      'abstract-psychedelic.png',
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
