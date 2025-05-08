import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { promises as fs } from 'fs';
import path from 'path';

import * as folders from '../src/fs/folders'; // ajusta esta ruta según tu estructura real

const TEST_DIR = path.resolve('__tests__/test-folder');
const SUB_DIR = path.join(TEST_DIR, 'subdir');
const FILES = ['test1.txt', 'test2.js'];

describe('Folder Utilities', () => {
  beforeAll(async () => {
    await folders.createFolder(TEST_DIR);
    await folders.createFolder(SUB_DIR);
    await Promise.all(FILES.map(file => fs.writeFile(path.join(TEST_DIR, file), 'hello')));
  });

  afterAll(async () => {
    await fs.rm(TEST_DIR, { recursive: true, force: true });
  });

  it('createFolder creates a folder', async () => {
    const newDir = path.join(TEST_DIR, 'new-folder');
    await folders.createFolder(newDir);
    const stat = await fs.stat(newDir);
    expect(stat.isDirectory()).toBe(true);
  });

  it('listFiles lists only files', async () => {
    const listed = await folders.listFiles(TEST_DIR);
    expect(listed.sort()).toEqual(FILES.sort());
  });

  it('isDirectory returns true for directories', () => {
    expect(folders.isDirectory(TEST_DIR)).toBe(true);
  });

  it('existsAndIsDirectory returns true for existing directories', () => {
    expect(folders.existsAndIsDirectory(TEST_DIR)).toBe(true);
  });

  it('resolveFilePath resolves correct full path', () => {
    const result = folders.resolveFilePath(TEST_DIR, 'file.txt');
    expect(result).toBe(path.resolve(TEST_DIR, 'file.txt'));
  });

  it('resolveFilePaths resolves multiple paths', () => {
    const resolved = folders.resolveFilePaths(TEST_DIR, FILES);
    expect(resolved).toEqual(FILES.map(f => path.resolve(TEST_DIR, f)));
  });

  it('getFiles returns full file paths', () => {
    const files = folders.getFiles(TEST_DIR);
    const expected = FILES.map(f => path.resolve(TEST_DIR, f));
    expect(files.sort()).toEqual(expected.sort());
  });

  it('getFilteredFiles filters files by extension', () => {
    const result = folders.getFilteredFiles(['.js'], TEST_DIR);
    const expected = [path.resolve(TEST_DIR, 'test2.js')];
    expect(result).toEqual(expected);
  });

  it('getFilteredFilesExcluding filters and excludes files', () => {
    const result = folders.getFilteredFilesExcluding(TEST_DIR, ['.txt', '.js'], [path.resolve(TEST_DIR, 'test1.txt')]);
    expect(result).toEqual([path.resolve(TEST_DIR, 'test2.js')]);
  });

  it('getFilesExcluding excludes specific files', () => {
    const allFiles = folders.getFiles(TEST_DIR);
    const result = folders.getFilesExcluding(TEST_DIR, [path.resolve(TEST_DIR, 'test2.js')]);
    expect(result).toEqual([path.resolve(TEST_DIR, 'test1.txt')]);
  });
});
