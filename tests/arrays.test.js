import { describe, it, expect } from 'vitest';
import {
  chunk,
  diff,
  hasArray,
  isArray,
  removeAllFalsy,
  unique,
} from '../src/array/index.js';

describe('Array Utilities', () => {
  describe('chunk', () => {
    it('should split array into chunks of given size', () => {
      const result = chunk([1, 2, 3, 4, 5], 2);
      expect(result).toEqual([[1, 2], [3, 4], [5]]);
    });

    it('should throw error for non-positive chunk size', () => {
      expect(() => chunk([1, 2, 3], 0)).toThrow('Size must be a positive number.');
    });

    it('should return the whole array if size >= length', () => {
      const result = chunk([1, 2], 5);
      expect(result).toEqual([[1, 2]]);
    });
  });

  describe('diff', () => {
    it('should return symmetric difference between two arrays', () => {
      const result = diff(['a', 'b'], ['a', 'b', 'c']);
      expect(result).toEqual(['c']);
    });

    it('should return all values if arrays are disjoint', () => {
      const result = diff(['x', 'y'], ['a', 'b']);
      expect(result.sort()).toEqual(['a', 'b', 'x', 'y'].sort());
    });

    it('should return empty array if arrays are equal', () => {
      const result = diff(['1', '2'], ['1', '2']);
      expect(result).toEqual([]);
    });
  });

  describe('hasArray', () => {
    it('should return true if object has at least one array', () => {
      const obj = { a: 1, b: [2, 3] };
      expect(hasArray(obj)).toBe(true);
    });

    it('should return false if object has no arrays', () => {
      const obj = { a: 1, b: 'string', c: {} };
      expect(hasArray(obj)).toBe(false);
    });
  });

  describe('isArray', () => {
    it('should return true for array', () => {
      expect(isArray([])).toBe(true);
    });

    it('should return false for non-array', () => {
      expect(isArray({})).toBe(false);
      expect(isArray('string')).toBe(false);
    });
  });

  describe('removeAllFalsy', () => {
    it('should remove falsy values', () => {
      const input = [0, 1, false, 2, '', 3, null, undefined, NaN];
      const result = removeAllFalsy(input);
      expect(result).toEqual([1, 2, 3]);
    });

    it('should return empty array if all values are falsy', () => {
      const input = [0, false, '', null, undefined, NaN];
      const result = removeAllFalsy(input);
      expect(result).toEqual([]);
    });
  });

  describe('unique', () => {
    it('should remove duplicate values', () => {
      const input = [1, 2, 2, 3, 3, 3, 4];
      const result = unique(input);
      expect(result).toEqual([1, 2, 3, 4]);
    });

    it('should return same array if no duplicates', () => {
      const input = [5, 6, 7];
      const result = unique(input);
      expect(result).toEqual([5, 6, 7]);
    });

    it('should handle empty array', () => {
      expect(unique([])).toEqual([]);
    });
  });
});
