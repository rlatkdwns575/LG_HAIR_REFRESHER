import fs from 'node:fs';

const file = process.argv[2];
const rootId = process.argv[3];
const content = fs.readFileSync(file, 'utf8');
const data = JSON.parse(content);

function walk(node, depth = 0, maxDepth = 6) {
  const indent = '  '.repeat(depth);
  const box = node.absoluteBoundingBox;
  const size = box
    ? `${Math.round(box.width)}x${Math.round(box.height)}`
    : '';
  const chars =
    node.characters != null ? ` "${node.characters.replace(/\n/g, '\\n')}"` : '';
  console.log(`${indent}${node.id} ${node.name} [${node.type}] ${size}${chars}`);
  if (depth >= maxDepth || !node.children) return;
  for (const child of node.children) {
    walk(child, depth + 1, maxDepth);
  }
}

walk(data);
