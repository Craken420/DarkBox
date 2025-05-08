import { describe, it, expect } from 'vitest'; // O puedes usar Jest
import * as fnArr from '../src/arrays/index.js';
/**
 * Test Suite for Function Utilities
 */
describe('Function Utilities Tests', () => {

  describe('Array Diff Utilities', () => {
    it('should return differences between arrays', () => {
      expect(fnArr.diff(['a', 'b'], ['a', 'b', 'c', 'd'])).toEqual(['c', 'd']);
      expect(fnArr.diff('abcd', 'abcde')).toEqual(['e']);
      expect(fnArr.diff('zxc', 'zxc')).toEqual([]); // No differences
    });
  });

  describe('Unique Utilities', () => {
    it('unique should remove duplicate values', () => {
      expect(arrays.unique([1, 2, 2, 3, 1])).toEqual([1, 2, 3]);
    });
  });

  describe('Chunk Utilities', () => {
    it('chunk should split an array into smaller arrays of given size', () => {
      expect(arrays.chunk([1, 2, 3, 4, 5], 2)).toEqual([[1, 2], [3, 4], [5]]);
    });
  });
})