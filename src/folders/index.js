/**
 * @file folder/index.js
 * @fileoverview Directory and folder utilities.
 * Includes functions to create, delete, traverse, and validate folder structures.
 *
 * @module folders
 */
import * as R from 'ramda';
import * as fs from 'fs';
import path from 'path';

/**
 * Creates a directory if it does not exist.
 * @param {string} dirPath - The path to the directory.
 * @returns {Promise<void>} A promise that resolves when the directory exists.
 */
const createFolder = async(dirPath) => await fs.mkdir(dirPath, { recursive: true });

/**
 * Checks if the given path is a directory.
 * @param {string} directoryPath - The path to check.
 * @returns {boolean} True if the path is a directory, false otherwise.
 */
const isDirectory = (directoryPath) => fs.statSync(directoryPath).isDirectory();

/**
 * Checks if the path exists and is a directory.
 * @param {string} directoryPath - The path to check.
 * @returns {boolean} True if the path exists and is a directory, false otherwise.
 */
const existsAndIsDirectory = R.both(fs.existsSync, isDirectory);

/**
 * Retrieves all files (not directories) within a directory.
 * @param {string} directory - The directory to scan.
 * @returns {string[]} Array of file paths.
 */
const getFiles = (directory) => {
  const files = fs.readdirSync(directory);
  const filePaths = resolveFilePaths(directory, files);
  return R.filter((filePath) => fs.statSync(filePath).isFile(), filePaths);
};

/**
 * Retrieves all files within a directory, excluding specified file names.
 * @param {string} directory - The directory to scan.
 * @param {string[]} namesToOmit - Array of file names to exclude.
 * @returns {string[]} Array of file paths not in the namesToOmit list.
 */
const getFilesExcluding = R.curry((directory, namesToOmit) => {
  const files = getFiles(directory);
  return R.without(namesToOmit, files);
});

/**
 * Retrieves files with specified extensions within a directory.
 * @param {string[]} extensions - Array of file extensions to filter by.
 * @param {string} directory - The directory to scan.
 * @returns {string[]} Array of file paths matching the extensions.
 */
const getFilteredFiles = R.curry((extensions, directory) => {
  const files = getFiles(directory);
  return R.filter((file) => extensions.includes(path.extname(file)), files);
});

/**
 * Retrieves files with specified extensions within a directory, excluding specified file names.
 * @param {string} directory - The directory to scan.
 * @param {string[]} extensions - Array of file extensions to filter by.
 * @param {string[]} namesToOmit - Array of file names to exclude.
 * @returns {string[]} Array of file paths matching the extensions and not in the namesToOmit list.
 */
const getFilteredFilesExcluding = R.curry((directory, extensions, namesToOmit) => {
  const files = getFilteredFiles(extensions, directory);
  return R.without(namesToOmit, files);
});

/**
 * Lists the files (not directories) within a directory.
 * @param {string} dirPath - The path to the directory.
 * @returns {Promise<string[]>} A promise that resolves with an array of file names.
 */
const listFiles = async(dirPath) => {
  const entries = await fs.readdir(dirPath, { withFileTypes: true });
  return entries
    .filter(dirent => dirent.isFile())
    .map(dirent => dirent.name);
}

/**
 * Resolves the full path for a given directory and file name.
 * @param {string} directory - The base directory.
 * @param {string} fileName - The name of the file.
 * @returns {string} The resolved file path.
 */
const resolveFilePath = R.curry((directory, fileName) => path.resolve(directory, fileName));

/**
 * Resolves full paths for multiple files within a directory.
 * @param {string} directory - The base directory.
 * @param {string[]} files - Array of file names.
 * @returns {string[]} Array of resolved file paths.
 */
const resolveFilePaths = R.curry((directory, files) => R.map((file) => resolveFilePath(directory, file), files));

export {
  createFolder,
  existsAndIsDirectory,
  getFiles,
  getFilesExcluding,
  getFilteredFiles,
  getFilteredFilesExcluding,
  isDirectory,
  listFiles,
  resolveFilePath,
  resolveFilePaths
};
  