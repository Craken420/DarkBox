import { createFolder, existsAndIsDirectory, getFiles, getFilesExcluding, getFilteredFiles, getFilteredFilesExcluding, isDirectory, listFiles, resolveFilePath, resolveFilePaths } from './folder/index';
import fs from 'fs';
import path from 'path';

// Mocking the fs module to simulate file system operations
jest.mock('fs', () => ({
  ...jest.requireActual('fs'),
  mkdir: jest.fn(),
  readdirSync: jest.fn(),
  statSync: jest.fn(),
  existsSync: jest.fn(),
}));

describe('Folder Utilities', () => {
  describe('createFolder', () => {
    it('should create the folder if it does not exist', async () => {
      fs.existsSync.mockReturnValue(false); // Simulate that the folder does not exist
      await createFolder('/path/to/dir');
      expect(fs.mkdir).toHaveBeenCalledWith('/path/to/dir', { recursive: true });
    });

    it('should do nothing if the folder exists', async () => {
      fs.existsSync.mockReturnValue(true); // Simulate that the folder exists
      await createFolder('/path/to/dir');
      expect(fs.mkdir).not.toHaveBeenCalled();
    });
  });

  describe('existsAndIsDirectory', () => {
    it('should return true if the path exists and is a directory', () => {
      fs.existsSync.mockReturnValue(true);
      fs.statSync.mockReturnValue({ isDirectory: () => true });
      expect(existsAndIsDirectory('/path/to/dir')).toBe(true);
    });

    it('should return false if the path does not exist', () => {
      fs.existsSync.mockReturnValue(false);
      expect(existsAndIsDirectory('/path/to/dir')).toBe(false);
    });

    it('should return false if the path exists but is not a directory', () => {
      fs.existsSync.mockReturnValue(true);
      fs.statSync.mockReturnValue({ isDirectory: () => false });
      expect(existsAndIsDirectory('/path/to/dir')).toBe(false);
    });
  });

  describe('getFiles', () => {
    it('should return an array of file paths', () => {
      fs.readdirSync.mockReturnValue(['file1.txt', 'file2.txt']);
      fs.statSync.mockReturnValue({ isFile: () => true });
      expect(getFiles('/path/to/dir')).toEqual(['/path/to/dir/file1.txt', '/path/to/dir/file2.txt']);
    });
  });

  describe('getFilesExcluding', () => {
    it('should exclude specified file names', () => {
      fs.readdirSync.mockReturnValue(['file1.txt', 'file2.txt', 'file3.txt']);
      fs.statSync.mockReturnValue({ isFile: () => true });
      const files = getFilesExcluding('/path/to/dir', ['file2.txt']);
      expect(files).toEqual(['/path/to/dir/file1.txt', '/path/to/dir/file3.txt']);
    });
  });

  describe('getFilteredFiles', () => {
    it('should return files with specified extensions', () => {
      fs.readdirSync.mockReturnValue(['file1.txt', 'file2.js', 'file3.txt']);
      fs.statSync.mockReturnValue({ isFile: () => true });
      const files = getFilteredFiles(['.txt'], '/path/to/dir');
      expect(files).toEqual(['/path/to/dir/file1.txt', '/path/to/dir/file3.txt']);
    });
  });

  describe('getFilteredFilesExcluding', () => {
    it('should return files with specified extensions and exclude certain files', () => {
      fs.readdirSync.mockReturnValue(['file1.txt', 'file2.js', 'file3.txt']);
      fs.statSync.mockReturnValue({ isFile: () => true });
      const files = getFilteredFilesExcluding('/path/to/dir', ['.txt'], ['file3.txt']);
      expect(files).toEqual(['/path/to/dir/file1.txt']);
    });
  });

  describe('isDirectory', () => {
    it('should return true if the path is a directory', () => {
      fs.statSync.mockReturnValue({ isDirectory: () => true });
      expect(isDirectory('/path/to/dir')).toBe(true);
    });

    it('should return false if the path is not a directory', () => {
      fs.statSync.mockReturnValue({ isDirectory: () => false });
      expect(isDirectory('/path/to/dir')).toBe(false);
    });
  });

  describe('listFiles', () => {
    it('should list files in a directory', async () => {
      fs.readdir.mockResolvedValue([
        { isFile: () => true, name: 'file1.txt' },
        { isFile: () => true, name: 'file2.txt' },
        { isFile: () => false, name: 'folder1' },
      ]);
      const files = await listFiles('/path/to/dir');
      expect(files).toEqual(['file1.txt', 'file2.txt']);
    });
  });

  describe('resolveFilePath', () => {
    it('should resolve the file path correctly', () => {
      expect(resolveFilePath('/path/to/dir', 'file1.txt')).toBe(path.resolve('/path/to/dir', 'file1.txt'));
    });
  });

  describe('resolveFilePaths', () => {
    it('should resolve multiple file paths correctly', () => {
      const files = ['file1.txt', 'file2.txt'];
      expect(resolveFilePaths('/path/to/dir', files)).toEqual([
        path.resolve('/path/to/dir', 'file1.txt'),
        path.resolve('/path/to/dir', 'file2.txt'),
      ]);
    });
  });
});
