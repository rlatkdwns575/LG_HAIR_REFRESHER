import fs from 'node:fs';

const file = process.argv[2];
const content = fs.readFileSync(file, 'utf8');
const re = /"id":"([^"]+)","name":"(홈[^"]+)"/g;
const entries = new Map();
let match;
while ((match = re.exec(content)) !== null) {
  entries.set(match[2], match[1]);
}
for (const [name, id] of [...entries.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
  console.log(`${id}\t${name}`);
}
