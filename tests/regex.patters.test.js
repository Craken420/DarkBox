import { describe, it, expect } from 'vitest';
import regex from '../src/regex.js';

describe('Regex Utilities Tests', () => {
  describe('JS Regex', () => {
    it('should extract argument names from function declaration', () => {
      const args = 'function(a, b, c)';
      const matches = args.match(regex.js.argNamesFromFn);
      expect(matches).toEqual(['a', 'b', 'c']);
    });

    it('should remove comments from JS code', () => {
      const code = `// this is a comment
      const a = 1; /* another comment */`;
      const cleaned = code.replace(regex.js.comments, '');
      expect(cleaned.includes('comment')).toBe(false);
    });

    it('should find const variable names', () => {
      const code = 'const myVar = 5;';
      const matches = code.match(regex.js.constantNames);
      expect(matches).toEqual(['myVar']);
    });
  });

  describe('File Regex', () => {
    it('should extract file extension', () => {
      const file = 'photo.jpeg';
      expect(file.match(regex.file.fileExtension)[0]).toBe('.jpeg');
    });

    it('should extract filename without extension', () => {
      const file = 'document.txt';
      expect(file.match(regex.file.pathWithoutExtension)[0]).toBe('document');
    });

    it('should extract path root', () => {
      const path = 'c:/projects/file.txt';
      expect(path.match(regex.file.pathRoot)[0]).toBe('c:/projects/');
    });
  });

  describe('INI File Regex', () => {
    it('should detect INI section header', () => {
      const header = '[Section.Name]';
      expect(regex.iniFile.sectionHeader.test(header)).toBe(true);
    });

    it('should extract filename from section header', () => {
      const header = '[Version.frm/AccionePerfilDBMail]';
      const match = header.match(regex.iniFile.fileNameFromSectionHeader);
      expect(match[0]).toBe('Version.frm');
    });

    it('should match key-value line', () => {
      const line = 'Nombre=PerfilDBMail';
      expect(line.match(regex.iniFile.fullKeyValue)).toEqual([line]);
    });
  });

  describe('SQL Regex', () => {
    it('should match ANSI SQL settings', () => {
      const line = 'SET ANSI_NULLS ON\nGO';
      const match = line.match(regex.sql.ANSISettings);
      expect(match.length).toBeGreaterThan(0);
    });

    it('should detect WITH(NOLOCK) hint', () => {
      const sql = 'SELECT * FROM table WITH(NOLOCK)';
      expect(regex.sql.detectNoLockHints.test(sql)).toBe(true);
    });

    it('should match SQL single-line comments', () => {
      const comment = '-- this is a comment';
      expect(regex.sql.lineComments.test(comment)).toBe(true);
    });
  });

  describe('RDP Regex', () => {
    it('should match abbreviation between underscores', () => {
      const text = 'User_FRM_Main';
      expect(text.match(regex.rdp.abbrBetweenUnderscores)[0]).toBe('FRM');
    });

    it('should match suffix after abbreviation', () => {
      const text = 'Modulo_tbl_Branch';
      expect(text.match(regex.rdp.postAbbreviationSuffix)[0]).toBe('_Branch');
    });

    it('should match prefix before abbreviation', () => {
      const text = 'App_dlg_Test';
      const match = text.match(regex.rdp.prefixBeforeAbbreviation);
      expect(match[0]).toContain('dlg');
    });
  });

  describe('String Regex', () => {
    it('should split string by non-alphanumeric characters', () => {
      const text = 'Hello, world!';
      const parts = text.split(regex.string.wordSplit);
      expect(parts).toEqual(['Hello', 'world']);
    });
  });
});

describe('INI File Regex - Extra Tests', () => {
    it('should match bracket of section header only if it opens properly', () => {
      const valid = '[Header]';
      const invalid = 'Header]';
      expect(regex.iniFile.bracketOfSectionHeader.test(valid)).toBe(true);
      expect(regex.iniFile.bracketOfSectionHeader.test(invalid)).toBe(false);
    });
  
    it('should match INI comments starting with ;', () => {
      expect(regex.iniFile.comments.test('; this is a comment')).toBe(true);
      expect(regex.iniFile.comments.test('# not a semicolon comment')).toBe(false);
    });
  
    it('should capture keys excluding header', () => {
      const input = `[Section]\nKey1=Value1\nKey2=Value2`;
      const matches = input.match(regex.iniFile.iniFileKeysWithoutHeader);
      expect(matches.join('\n')).toContain('Key1=Value1');
    });
  
    it('should match full INI block with key in header', () => {
      const input = '[Block]\nkey=value';
      expect(regex.iniFile.iniFileWithKeyInHeader.test(input)).toBe(true);
    });
  
    it('should match section with comments', () => {
      const input = `; comment\n[Block]\nKey=value`;
      expect(input.match(regex.iniFile.sectionWithComments)).toBeTruthy();
    });
  
    it('should match section without comments', () => {
      const input = `[Block]\nKey1=value1\nKey2=value2`;
      expect(input.match(regex.iniFile.sectionWithoutComments)[0]).toContain('Key1=value1');
    });
  });
  
  describe('SQL Regex - Extra Tests', () => {
    it('should detect null comparison in CASE WHEN', () => {
      const sql = `
        CASE WHEN value = NULL THEN 'yes' ELSE 'no' END
      `;
      expect(regex.sql.detectNullComparisonInCaseWhen.test(sql)).toBe(true);
    });
  
    it('should match multiline comments', () => {
      const comment = `/* This is 
      a multiline
      comment */`;
      expect(comment.match(regex.sql.mltilineComments)[0]).toContain('This is');
    });
  
    it('should detect null comparison using symbols in CASE', () => {
      const sql = `case when column != null then 'ok' else 'no' end`;
      expect(regex.sql.nullComparisonInCase.test(sql)).toBe(true);
    });
  });
  
  describe('RDP Regex - Extra Tests', () => {
    it('should match expression and Wizard block', () => {
      const input = `Expresion=...Sino<br>...Forma.Accion(<T>WizardSituaciones<T>)`;
      expect(regex.rdp.expressionAndWizardBlock.test(input)).toBe(true);
    });
  
    it('should match key-value style Wizard expression', () => {
      const line = `Expresion=if x then y Sino<br> Forma.Accion(<T>WizardSituaciones<T>)`;
      expect(regex.rdp.expressionWithWizardFromKeyValue.test(line)).toBe(true);
    });
  
    it('should match Wizard situation inside [Acciones.Situacion] block', () => {
      const block = `[Acciones.Situacion]
        Expresion=Condicion Sino<br> Forma.Accion(<T>WizardSituaciones<T>)`;
      const match = block.match(regex.rdp.expressionWithWizardInSituation);
      expect(match).toBeTruthy();
    });
});
