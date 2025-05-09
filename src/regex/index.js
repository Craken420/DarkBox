/**
 * @file regex/index.js
 * @fileoverview Main entry point for the regex module.
 * Exports all utility modules: patterns, etc.
 */

import * as adapter from './adapter';
import * as cls from './cls';
import * as make from './make';
import * as match from './match';
import * as patterns from './patterns';

export {
    adapter,
    cls,
    make,
    match,
    patterns
};