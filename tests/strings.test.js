import { describe, it, expect } from 'vitest'; // O usa jest
import * as fnString from '../src/strings/index.js';


describe('Text Utilities', () => {
  describe('compareTextByPhraseSimilarity', () => {
    it('should find common fragments and differences', () => {
      const result = fnString.compareTextByPhraseSimilarity('el perro corre', 'el gato corre');
      expect(result).toEqual({
        differences1: ['perro'],
        differences2: ['gato'],
        coincidences: ['el', 'corre'],
      });
    });

    it('should return all as differences if no match', () => {
      const result = fnString.compareTextByPhraseSimilarity('uno dos tres', 'cuatro cinco');
      expect(result).toEqual({
        differences1: ['uno dos tres'],
        differences2: ['cuatro cinco'],
        coincidences: [],
      });
    });

    it('should handle empty inputs', () => {
      const result = fnString.compareTextByPhraseSimilarity('', '');
      expect(result).toEqual({
        differences1: [],
        differences2: [],
        coincidences: [],
      });
    });
  });

  describe('checkDifferencesByLength', () => {
    it('should return fragments from text1 not in text2', () => {
      const result = fnString.checkDifferencesByLength('hola mundo bonito', 'hola planeta bonito', 2);
      expect(result).toEqual(['mundo bonito']);
    });

    it('should return empty array if all fragments exist in text2', () => {
      const result = fnString.checkDifferencesByLength('a b c d', 'a b c d', 2);
      expect(result).toEqual([]);
    });

    it('should return empty array if not enough words', () => {
      const result = fnString.checkDifferencesByLength('hola', 'mundo', 2);
      expect(result).toEqual([]);
    });
  });

  describe('capitalize', () => {
    it('should capitalize first letter', () => {
      expect(fnString.capitalize('hola')).toBe('Hola');
    });

    it('should handle empty string', () => {
      expect(fnString.capitalize('')).toBe('');
    });

    it('should throw error if not string', () => {
      expect(() => fnString.capitalize(null)).toThrow(TypeError);
      expect(() => fnString.capitalize(123)).toThrow(TypeError);
    });
  });

  describe('kebabCase', () => {
    it('should convert to kebab-case', () => {
      expect(fnString.kebabCase('Hola Mundo Bonito')).toBe('hola-mundo-bonito');
      expect(fnString.kebabCase('esto_es una-prueba')).toBe('esto-es-una-prueba');
    });
  });

  describe('camelCase', () => {
    it('should convert to camelCase', () => {
      expect(fnString.camelCase('Hola mundo bonito')).toBe('holaMundoBonito');
      expect(fnString.camelCase('esto_es una-prueba')).toBe('estoEsUnaPrueba');
    });
  });
});
