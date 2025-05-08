/**
 * @fileoverview Main entry point for the darckbox library.
 * Re-exports all utility modules: arrays, objects, strings, files, folders, and encoding.
 * Use this file to access the entire library from a single import.
 */

import * as arrays from './arrays/index.js';
import * as objects from './objects/index.js';
import * as strings from './strings/index.js';
import * as files from './files/index.js';
import * as folders from './folders/index.js';
import * as encoding from './encoding/index.js';

export const DarckBox = {
  arrays,
  objects,
  strings,
  files,
  folders,
  encoding
};