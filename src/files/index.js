/**
 * @fileoverview File system utilities.
 * Allows reading, writing, validating, and processing files on disk.
 * 
 * @module files
 */

/**
 * Reads the contents of a text file asynchronously.
 * @param {string} filePath - The path to the file.
 * @returns {Promise<string>} A promise that resolves with the file contents.
 */
const readFile = async (filePath) => fs.readFile(filePath, 'utf-8');
  
/**
 * Writes text to a file asynchronously, creating or overwriting it.
 * @param {string} filePath - The path to the file.
 * @param {string} data - The text to write.
 * @returns {Promise<void>} A promise that resolves when writing is complete.
 */
const writeFile = async(filePath, data) => fs.writeFile(filePath, data, 'utf-8');

/**
 * Checks if a path points to a file.
 * @param {string} file - Path to check.
 * @returns {boolean}
 */
const isFile = file => fs.statSync(file).isFile()

/**
 * Checks if a file exists and is a file.
 * @param {string} file - Path to check.
 * @returns {boolean}
 */
const existsAndIsFile = R.both(fs.existsSync, isFile)

/**
 * Reads a directory and returns the absolute paths of all files/directories inside.
 * @param {string} dir - Directory path.
 * @returns {string[]}
 */
const getPathsInDir = dir => fs.readdirSync(dir).map(x => path.resolve(dir, x))

/**
 * Filters files by extension.
 * @param {string[]} extensions - Array of extensions (e.g., ['.txt']).
 * @param {string[]} files - Array of file paths.
 * @returns {string[]}
 */
const filterFilesByExt = R.curry((extensions, files) =>
  files.filter(x => extensions.includes(path.extname(x)) && fs.statSync(x).isFile())
)

/**
 * Gets filtered files by extensions from a directory.
 * @param {string[]} extensions - Extensions to filter.
 * @param {string} dir - Directory path.
 * @returns {string[]}
 */
const getFilteredFilesInDir = R.curry((extensions, dir) =>
  filterFilesByExt(extensions, getPathsInDir(dir))
)

/**
 * Creates an empty file if it does not exist.
 * @param {string} file - File path.
 * @returns {{file: string, status: 'Created' | 'Exist'}}
 */
const checkAndCreateFile = file => {
  if (fs.existsSync(file)) {
    return { file, status: 'Exist' }
  } else {
    fs.writeFileSync(file, '', 'latin1')
    return { file, status: 'Created' }
  }
}

/**
 * Deletes file if it is empty.
 * @param {string} file - Path to the file.
 * @returns {boolean} - True if deleted, false if not.
 */
const deleteIfEmpty = file => {
  if (!fs.readFileSync(file).toString()) {
    console.log('Delete:', path.basename(file))
    fs.unlinkSync(file)
    return true
  }
  return false
}

/**
 * Joins a base directory with a file name and replaces extension with '_esp.txt'.
 * @param {string} dir - Base directory.
 * @param {string} file - Original file path.
 * @returns {string}
 */
const toEspFilenameInDir = R.curry((dir, file) =>
  path.join(dir, path.basename(file).replace(/\.[^.]+$/, '_esp.txt'))
)

/**
 * Checks if the file exists in ESP form, or creates it.
 * @param {string} dir - Directory.
 * @param {string} file - Original file.
 * @returns {{file: string, status: 'Created' | 'Exist'}}
 */
const toEspFileCheckAndCreate = R.curry((dir, file) =>
  checkAndCreateFile(toEspFilenameInDir(dir, file))
)

module.exports = {
    readFile,
    writeFile,
    isFile,
    existsAndIsFile,
    getPathsInDir,
    filterFilesByExt,
    getFilteredFilesInDir,
    checkAndCreateFile,
    deleteIfEmpty,
    toEspFilenameInDir,
    toEspFileCheckAndCreate
}