#!/usr/bin/env node
'use strict';
/*
 * SysScope — npx launcher
 * Lets anyone run the audit with no install/clone:
 *     npx github:aoneahsan/sysscope
 * This shim simply runs the self-contained bundled bash script and passes
 * through all CLI args + the exit code. It does NOT read or transmit anything.
 */
const { spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const root = path.resolve(__dirname, '..');
const bundle = path.join(root, 'audit-bundle.sh');
const modular = path.join(root, 'audit.sh');
const script = fs.existsSync(bundle) ? bundle : modular;

if (!fs.existsSync(script)) {
  console.error('SysScope: could not find audit-bundle.sh or audit.sh next to this launcher.');
  process.exit(1);
}

const res = spawnSync('bash', [script].concat(process.argv.slice(2)), { stdio: 'inherit' });

if (res.error) {
  if (res.error.code === 'ENOENT') {
    console.error('SysScope needs "bash", available on macOS, Linux, and Windows via WSL/Git Bash.');
  } else {
    console.error('SysScope failed to launch:', res.error.message);
  }
  process.exit(1);
}
process.exit(res.status === null ? 1 : res.status);
