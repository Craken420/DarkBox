import { describe, it, expect } from 'vitest';
import * as iniMatchers from '../src/utils/iniMatchers.js';

describe('INI Matcher Utilities', () => {

  const sampleINI = `
    [file.ini/Section1]
    key1=value1
    key2=value2

    [AnotherSection]
    keyA=valueA
    keyB=valueB

    [file.ini/Section_Wizard_Step1]
    step=WizardStep
  `;

  describe('findSectionByName', () => {
    it('should find a section by exact name', () => {
      const result = iniMatchers.findSectionByName('AnotherSection', sampleINI);
      expect(result).toBeTruthy();
      expect(result[0]).toContain('[AnotherSection]');
    });

    it('should return false if section not found', () => {
      expect(iniMatchers.findSectionByName('NoSection', sampleINI)).toBe(false);
    });
  });

  describe('findSectionByFileName', () => {
    it('should find sections by filename prefix', () => {
      const result = iniMatchers.findSectionByFileName('file.ini', sampleINI);
      expect(result).toBeTruthy();
      expect(result.length).toBeGreaterThan(0);
    });
  });

  describe('matchAbbreviationBetweenLowScripts', () => {
    it('should match abbreviations between underscores', () => {
      const testText = 'prefix_ABR_ suffix';
      const result = iniMatchers.matchAbbreviationBetweenLowScripts(testText);
      expect(result).toEqual(['_ABR_']);
    });
  });

  describe('matchAllSections', () => {
    it('should return all section headers', () => {
      const result = iniMatchers.matchAllSections(sampleINI);
      expect(result).toBeTruthy();
      expect(result.length).toBeGreaterThan(1);
    });
  });

  describe('matchBeforeAbbreviation', () => {
    it('should match text before abbreviation', () => {
      const testText = 'RDP_ABR_1';
      const result = iniMatchers.matchBeforeAbbreviation(testText);
      expect(result).toBeTruthy();
    });
  });

  describe('matchElseWizardSituation', () => {
    it('should find expressions with Wizard in them', () => {
      const result = iniMatchers.matchElseWizardSituation(sampleINI);
      expect(result).toBeTruthy();
    });
  });

  describe('matchFullKey', () => {
    it('should match key=value pairs', () => {
      const result = iniMatchers.matchFullKey(sampleINI);
      expect(result).toContain('key1=value1');
      expect(result).toContain('step=WizardStep');
    });
  });

  describe('matchKeyContent', () => {
    it('should extract value of a specific key', () => {
      const result = iniMatchers.matchKeyContent('keyA', sampleINI);
      expect(result).toContain('keyA=valueA');
    });
  });

  describe('matchKeyName', () => {
    it('should extract all key names', () => {
      const result = iniMatchers.matchKeyName(sampleINI);
      expect(result).toContain('key1');
      expect(result).toContain('keyB');
    });
  });

  describe('matchSectionHeader', () => {
    it('should extract section headers', () => {
      const result = iniMatchers.matchSectionHeader(sampleINI);
      expect(result).toContain('[file.ini/Section1]');
    });
  });

  describe('matchSectionNameFile', () => {
    it('should extract filenames from section headers', () => {
      const result = iniMatchers.matchSectionNameFile(sampleINI);
      expect(result).toBeTruthy();
      expect(result[0]).toContain('file.ini');
    });
  });

  describe('matchSectionOutside', () => {
    it('should find sections not matching a specific name', () => {
      const result = iniMatchers.matchSectionOutside('AnotherSection', sampleINI);
      expect(result).toBeTruthy();
      expect(result.some(r => r.includes('AnotherSection'))).toBe(false);
    });
  });
});
