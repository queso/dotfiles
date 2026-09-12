#!/usr/bin/env node
// Convert a HEIC/HEIF file to JPEG next to it. Used by screenshot-relay.sh
// so iPhone photos fetched from the Mac are readable by Claude.
// Usage: heic-to-jpg.js <input.heic> [output.jpg]
// Deps live outside dotfiles: ~/.local/share/screenshot-relay/node_modules
const path = require("path");
const fs = require("fs");
const os = require("os");

module.paths.push(path.join(os.homedir(), ".local/share/screenshot-relay/node_modules"));
const convert = require("heic-convert");

const input = process.argv[2];
if (!input) {
  console.error("usage: heic-to-jpg.js <input.heic> [output.jpg]");
  process.exit(2);
}
const output = process.argv[3] || input.replace(/\.(heic|heif)$/i, ".jpg");

(async () => {
  const buffer = fs.readFileSync(input);
  const jpg = await convert({ buffer, format: "JPEG", quality: 0.85 });
  fs.writeFileSync(output, Buffer.from(jpg));
  process.stdout.write(output);
})().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
