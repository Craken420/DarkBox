import { describe, it, expect } from 'vitest'; // O puedes usar Jest
import * as makeRgx from '../src/regex/make';

/**
 * Test Suite for INI and SQL Matching Functions
 */
describe('INI and SQL Matching Functions Tests', () => {

    describe('INI File Matching', () => {
      it('should match the full section content by adapted section name', () => {
        const input = '[MySection]\nkey=value';
        const regex = makeRgx.matchFullSection('MySection');
        expect(input).toMatch(regex);
      });
  
      it('should match the full section content without adaptation to the section name', () => {
        const input = '[MySection]\nkey=value';
        const regex = makeRgx.matchFullSectionRaw('MySection');
        expect(input).toMatch(regex);
      });
  
      it('should match section content with file prefix', () => {
        const input = '[config.ini/Database]\nhost=localhost';
        const regex = makeRgx.iniFileSectionByBaseFile('config.ini');
        expect(input).toMatch(regex);
      });
  
      it('should match a section header constructed from dynamic parts', () => {
        const input = '[UserConfig]\nkey=value';
        const regex = makeRgx.matchSectionHeader(['User', 'Config']);
        expect(input).toMatch(regex);
      });
  
      it('should match a section header without adaptation', () => {
        const input = '[MySection]\nkey=value';
        const regex = makeRgx.matchSectionHeaderRaw('MySection');
        expect(input).toMatch(regex);
      });
  
      it('should match content specifically at the end of a section', () => {
        const input = '[FinalBlock]\nfoo=bar';
        const regex = makeRgx.sectionAtEnd('FinalBlock');
        expect(input).toMatch(regex);
      });
  
      it('should match all sections except the specified one', () => {
        const input = '[OtherSection/Sub]\nkey=val';
        const regex = makeRgx.matchOtherSections('Config');
        expect(input).toMatch(regex);
      });
  
      it('should extract the value of a key from an INI section', () => {
        const input = 'myField=someValue';
        const regex = makeRgx.matchKeyValue('myField');
        expect(input).toMatch(regex);
      });
    });
  
    describe('SQL Matching', () => {
      it('should match a condition comparing to NULL', () => {
        const input = 'user.status = NULL';
        const regex = makeRgx.sqlCompareWithNull('status');
        expect(input).toMatch(regex);
      });
  
      it('should match the comparison operator used in a NULL comparison', () => {
        const input = 'user.status = NULL';
        const regex = makeRgx.sqlCompareSymbolWithNull('status');
        expect(input).toMatch(regex);
      });
    });
});