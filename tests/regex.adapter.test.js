import { toObject, toRegExp } from './adapter'; // Ajusta la ruta si es necesario

describe('toObject', () => {
    it('should convert INI-style text to object-like format', () => {
        const input = '[config.ini/Database]\nhost=localhost\nport=3306';
        const expected = 'config.ini:Database\nhost:localhost\nport:3306';
        expect(toObject(input)).toBe(expected);
    });

    it('should remove brackets and slashes', () => {
        const input = '[example/file]\nkey=value';
        const expected = 'example:file\nkey:value';
        expect(toObject(input)).toBe(expected);
    });

    it('should preserve dots and colons, format commas with space', () => {
        const input = '[config/file]\na.b=value1,value2';
        const expected = 'config:file\nab:value1, value2';
        expect(toObject(input)).toBe(expected);
    });

    it('should strip unwanted characters', () => {
        const input = '[name/file*]\nweird-key=value!';
        const result = toObject(input);
        expect(result).not.toMatch(/[*!=]/);
    });

    it('should handle empty input', () => {
        expect(toObject('')).toBe('');
    });
});

describe('toRegExp', () => {
    it('should escape square brackets', () => {
        expect(toRegExp('[section]')).toBe('\\[section\\]');
    });

    it('should escape curly braces', () => {
        expect(toRegExp('{key}')).toBe('\\{key\\}');
    });

    it('should escape parentheses and question mark group', () => {
        expect(toRegExp('(?test)')).toBe('\\(\\?test\\)');
    });

    it('should escape special characters including +, *, $, ., \\', () => {
        const input = '+ * $ . \\';
        const expected = '\\+\\s\\*\\s\\$\\s\\.\\s\\\\';
        expect(toRegExp(input)).toBe(expected);
    });

    it('should convert newlines and spaces', () => {
        const input = 'line 1\nline 2';
        const expected = 'line\\s1\\nline\\s2';
        expect(toRegExp(input)).toBe(expected);
    });

    it('should handle empty string', () => {
        expect(toRegExp('')).toBe('');
    });
});
