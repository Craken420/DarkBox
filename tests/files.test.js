import fs from 'fs';
import path from 'path';
import * as files from './index';

jest.mock('fs');
jest.mock('path');

// Aquí definimos algunos mocks para pruebas
const mockFile = path.resolve('test.txt');

beforeEach(() => {
  jest.clearAllMocks();
});

describe('File Utilities', () => {
  describe('checkAndCreateFile', () => {
    it('should create a file if it does not exist', () => {
      fs.existsSync.mockReturnValue(false);
      fs.writeFileSync.mockImplementation(() => {});

      const result = files.checkAndCreateFile(mockFile);

      expect(result.status).toBe('Created');
      expect(fs.writeFileSync).toHaveBeenCalledWith(mockFile, '', 'latin1');
    });

    it('should return status "Exist" if file already exists', () => {
      fs.existsSync.mockReturnValue(true);

      const result = files.checkAndCreateFile(mockFile);

      expect(result.status).toBe('Exist');
    });
  });

  describe('deleteIfEmpty', () => {
    it('should delete the file if it is empty', () => {
      fs.readFileSync.mockReturnValue('');
      fs.unlinkSync.mockImplementation(() => {});

      const result = files.deleteIfEmpty(mockFile);

      expect(result).toBe(true);
      expect(fs.unlinkSync).toHaveBeenCalledWith(mockFile);
    });

    it('should not delete the file if it is not empty', () => {
      fs.readFileSync.mockReturnValue('Non-empty content');

      const result = files.deleteIfEmpty(mockFile);

      expect(result).toBe(false);
      expect(fs.unlinkSync).not.toHaveBeenCalled();
    });
  });

  describe('filterFilesByExt', () => {
    it('should filter files by given extensions', () => {
      const filesArray = ['test.txt', 'image.jpg', 'document.txt'];
      const extensions = ['.txt'];

      const result = files.filterFilesByExt(extensions, filesArray);

      expect(result).toEqual(['test.txt', 'document.txt']);
    });
  });

  describe('getPathsInDir', () => {
    it('should return the absolute paths of all files in a directory', () => {
      const mockDir = '/mock/directory';
      const mockFiles = ['test1.txt', 'test2.txt'];
      path.resolve.mockImplementation((dir, file) => path.join(dir, file));
      fs.readdirSync.mockReturnValue(mockFiles);

      const result = files.getPathsInDir(mockDir);

      expect(result).toEqual([
        path.join(mockDir, 'test1.txt'),
        path.join(mockDir, 'test2.txt')
      ]);
    });
  });

  describe('toEspFileCheckAndCreate', () => {
    it('should create or check for the existence of the ESP version of a file', () => {
      fs.existsSync.mockReturnValue(false);
      fs.writeFileSync.mockImplementation(() => {});
      path.basename.mockReturnValue('test.txt');

      const result = files.toEspFileCheckAndCreate('dir', 'test.txt');

      expect(result.status).toBe('Created');
    });
  });

  describe('writeFile', () => {
    it('should write data to a file', async () => {
      const data = 'Some content';
      const filePath = '/mock/path.txt';

      fs.writeFile.mockImplementation((path, data, encoding, callback) => callback(null));

      await files.writeFile(filePath, data);

      expect(fs.writeFile).toHaveBeenCalledWith(filePath, data, 'utf-8', expect.any(Function));
    });
  });
});
