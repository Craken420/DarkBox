import * as fnUtils from '../src/utils/index';

/**
 * Test Suite for Function Utilities
 */
describe('Function Utilities Tests', () => {

  describe('isFunction', () => {
    test('should return true for a function', () => {
      const result = fnUtils.isFunction(function() {});
      expect(result).toBe(true);
    });

    test('should return false for non-function values', () => {
      const result = fnUtils.isFunction({});
      expect(result).toBe(false);

      const result2 = fnUtils.isFunction('string');
      expect(result2).toBe(false);

      const result3 = fnUtils.isFunction(123);
      expect(result3).toBe(false);

      const result4 = fnUtils.isFunction(null);
      expect(result4).toBe(false);
    });
  });

  describe('getFunctionName', () => {
    test('should return function name for named function', () => {
      const result = fnUtils.getFunctionName(function testFunc() {});
      expect(result).toBe('testFunc');
    });

    test('should return empty string for anonymous function', () => {
      const result = fnUtils.getFunctionName(function() {});
      expect(result).toBe('');
    });

    test('should throw TypeError for non-function input', () => {
      expect(() => fnUtils.getFunctionName('string')).toThrow(TypeError);
    });
  });

  describe('getParameterNames', () => {
    test('should return parameter names as an array for a function', () => {
      const result = fnUtils.getParameterNames(function(a, b, c) {});
      expect(result).toEqual(['a', 'b', 'c']);
    });

    test('should return empty array for function with no parameters', () => {
      const result = fnUtils.getParameterNames(function() {});
      expect(result).toEqual([]);
    });

    test('should handle function with default parameters', () => {
      const result = fnUtils.getParameterNames(function(a, b = 1) {});
      expect(result).toEqual(['a', 'b']);
    });

    test('should handle function with rest parameters', () => {
      const result = fnUtils.getParameterNames(function(a, ...rest) {});
      expect(result).toEqual(['a', 'rest']);
    });

    test('should remove comments and return correct parameters', () => {
      const result = fnUtils.getParameterNames(function(a, /* comment */ b) {});
      expect(result).toEqual(['a', 'b']);
    });
  });

  describe('Function Utilities', () => {
    it('debounce should delay function calls', async () => {
      const fn = vi.fn();
      const debounced = functions.debounce(fn, 50);
      debounced();
      debounced();
      expect(fn).not.toHaveBeenCalled();
      await new Promise(r => setTimeout(r, 60));
      expect(fn).toHaveBeenCalledTimes(1);
    });
  });
});
