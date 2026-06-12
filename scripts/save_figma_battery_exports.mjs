import fs from 'node:fs';
import path from 'node:path';

const terminalLog = process.argv[2];
const outputDir = process.argv[3];

if (!terminalLog || !outputDir) {
  console.error(
    'Usage: node scripts/save_figma_battery_exports.mjs <terminal-log> [output-dir=assets/images/home/battery]',
  );
  process.exit(1);
}

const nodeToState = {
  '951:20425': 0,
  '951:20426': 10,
  '951:20427': 30,
  '951:20431': 40,
  '951:20428': 50,
  '951:20429': 60,
  '951:20430': 80,
  '951:20432': 100,
};

const log = fs.readFileSync(terminalLog, 'utf8');
fs.mkdirSync(outputDir, { recursive: true });

const saved = new Set();

for (const [nodeId, state] of Object.entries(nodeToState)) {
  const marker = `"nodeId": "${nodeId}"`;
  let searchFrom = 0;
  let imageData;

  while (true) {
    const nodeIndex = log.indexOf(marker, searchFrom);
    if (nodeIndex === -1) {
      break;
    }

    const imageIndex = log.indexOf('"imageData": "', nodeIndex);
    if (imageIndex === -1) {
      searchFrom = nodeIndex + marker.length;
      continue;
    }

    const start = imageIndex + '"imageData": "'.length;
    const end = log.indexOf('"', start);
    imageData = log.slice(start, end);
    searchFrom = end + 1;
  }

  if (!imageData) {
    continue;
  }

  const filePath = path.join(outputDir, `icon_battery_24_state_${state}.png`);
  fs.writeFileSync(filePath, Buffer.from(imageData, 'base64'));
  saved.add(state);
  console.log(`saved ${filePath}`);
}

if (saved.size === 0) {
  console.error('No battery exports found in log.');
  process.exit(1);
}

const missing = Object.values(nodeToState).filter((state) => !saved.has(state));
console.log(`Saved ${saved.size} icon(s).`);
if (missing.length > 0) {
  console.log(`Missing states: ${missing.join(', ')}`);
}
