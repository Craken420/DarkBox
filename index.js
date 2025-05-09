/**
 * @fileoverview Main entry point for the darckbox library.
 * Re-exports all utility modules: arrays, objects, strings, files, folders, and encoding.
 * Use this file to access the entire library from a single import.
 */

import * as arrays from './src/arrays/index.js';
import * as encoding from './src/encoding/index.js';
import * as files from './src/files/index.js';
import * as folders from './src/folders/index.js';
import * as objects from './src/objects/index.js';
import * as regex from './src/regex/index.js';
import * as strings from './src/strings/index.js';

export const DarckBox = {
  arrays,
  encoding,
  files,
  folders,
  objects,
  regex,
  strings
};