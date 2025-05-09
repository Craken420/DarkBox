import { describe, it, expect } from 'vitest';
import { iniFile, path, rdp, sql, txt } from '../src/utils/cleaners.js';

describe('INI File Utilities', () => {
  it('removeComments should strip inline comments', () => {
    const input = 'key=value ; this is a comment';
    const result = iniFile.removeComments(input);
    expect(result).toBe('key=value ');
  });

  it('removeComparisonsOutsideHeader should remove text outside header', () => {
    const input = '[header]\nkey=value\n[other]\ncompare=1';
    const result = iniFile.removeComparisonsOutsideHeader('header', input);
    expect(result.includes('compare=1')).toBe(false);
  });

  it('removeContentOutsideHeader should keep only content inside header', () => {
    const input = '[header]\nkey=value\n[other]\nremove=this';
    const result = iniFile.removeContentOutsideHeader('header', input);
    expect(result).toContain('[header]');
    expect(result).not.toContain('[other]');
  });

  it('removeHeaderlessComparisons should strip keys not under header', () => {
    const input = 'lonelyKey=value\n[section]\nkey=value';
    const result = iniFile.removeHeaderlessComparisons(input);
    expect(result).not.toContain('lonelyKey');
  });
});

describe('Path Utilities', () => {
  it('removePathUntilExtension should remove path up to extension', () => {
    const input = '/some/dir/file.ext more text';
    const result = path.removePathUntilExtension(input);
    expect(result).toBe(' more text');
  });

  it('removeRootFromPath should strip root path', () => {
    const input = 'C:/root/folder/file.txt';
    const result = path.removeRootFromPath(input);
    expect(result).not.toContain('C:/root');
  });
});

describe('RDP Utilities', () => {
  it('removeAfterAbbreviationInObj should cut after abbreviation', () => {
    const input = 'OBJECT_NAME_abbr_trailing_text';
    const result = rdp.removeAfterAbbreviationInObj(input);
    expect(result).not.toContain('trailing_text');
  });

  it('removeHeaderlessComparisons should clean headerless keys', () => {
    const input = 'orphanKey=42\n[section]\nkey=1';
    const result = rdp.removeHeaderlessComparisons(input);
    expect(result).not.toContain('orphanKey');
  });

  it('cleanText should normalize and clean SQL/RDP text', () => {
    const input = '\tSELECT * FROM table WITH (NOLOCK) --comment\n';
    const result = rdp.cleanText(input);
    expect(result).not.toContain('--');
    expect(result).not.toContain('nolock');
    expect(result).not.toContain('\t');
    expect(result).toBe(result.toLowerCase());
  });
});

describe('SQL Utilities', () => {
  it('removeAnsiControlChars should remove ANSI settings', () => {
    const input = 'SET ANSI_NULLS ON;';
    const result = sql.removeAnsiControlChars(input);
    expect(result).not.toContain('ANSI_NULLS');
  });

  it('removeLineComments should remove single-line comments', () => {
    const input = 'SELECT * FROM users -- comment';
    const result = sql.removeLineComments(input);
    expect(result).not.toContain('--');
  });

  it('removeMultilineCommentsRecursively should remove all multiline comments', () => {
    const input = 'SELECT /* multi\nline\ncomment */ * FROM table /* second */';
    const result = sql.removeMultilineCommentsRecursively(input);
    expect(result).not.toContain('/*');
  });

  it('removeWithNoClauses should remove WITH (NOLOCK)', () => {
    const input = 'SELECT * FROM table WITH (NOLOCK)';
    const result = sql.removeWithNoClauses(input);
    expect(result).not.toContain('NOLOCK');
  });
});

describe('Text Utilities', () => {
  it('normalizeSpacesInLines should reduce spaces to single space', () => {
    const input = 'this    is   spaced\nnext   line';
    const result = txt.normalizeSpacesInLines(input);
    expect(result).toBe('this is spaced\nnext line');
  });

  it('removeAmpersands should remove all & symbols', () => {
    const input = 'A & B & C';
    const result = txt.removeAmpersands(input);
    expect(result).toBe('A  B  C');
  });

  it('removeEmptyLines should delete empty lines', () => {
    const input = 'line 1\n\nline 2\n\n';
    const result = txt.removeEmptyLines(input);
    expect(result).toBe('line 1\nline 2');
  });

  it('removeTabs should delete all tabs', () => {
    const input = '\tTabbed\tLine\t';
    const result = txt.removeTabs(input);
    expect(result).toBe('TabbedLine');
  });

  it('trimEachLine should trim each line', () => {
    const input = '  line1  \r  line2  \r';
    const result = txt.trimEachLine(input);
    expect(result).toBe('line1\nline2');
  });
});
