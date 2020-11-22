// DEV
// const String serverIP = '165.227.178.14'; // This doesn't work
// const String serverURL = 'thedogbarksthesong.ml';
// const String bucketName = 'song_barker_sequences';

// PROD
const String serverIP = 'k-9karaoke.com';
const String serverURL = 'thedogbarksthesong.ml'; // this is going to change
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
