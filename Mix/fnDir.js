const R = require('ramda')
const fs        = require('fs')
const path = require('path')

module.exports.fnDir = (function () {

    const _isDir = dir => fs.statSync(dir).isDirectory()

    const _existAndIsDir = R.both(fs.existsSync, isDir)

    const _isDirReadAgain = path => ( fs.statSync(path).isDirectory() ) ? getDeepFiles(path) : path

    const _getDeepFiles = dir => R.map(isDirReadAgain, conctsDirs( fs.readdirSync(dir), dir ) )

    const _conctDir = R.curry( (dir, fileName) => path.resolve(dir, fileName) )

    const _conctsDirs = R.curry( (dir, files) => R.map(file => conctDir(dir,  file), files) )

    const _conctsDirsIsFile = R.pipe(
        conctsDirs,
        R.filter( file => fs.statSync(file).isFile() )
    )

    const _getFiles = dir => conctsDirsIsFile( fs.readdirSync(dir), dir )

    const _chekAndGetFiles = R.both(existAndIsDir, getFiles)

    const _getFiltFiles = R.curry(
        (ext, dir) => R.filter(file => ext.indexOf( path.extname(file) ) > -1, getFiles(dir) ) )
        
    const _chekAndGetFiltFls = R.curry(
        (ext, dir) => R.filter(file => ext.indexOf( path.extname(file) ) > -1, chekAndGetFiles(dir) ) )

    const _getFiltFilesAndOmit = R.curry( (dir, ext, namesOmit) => R.without(
            namesOmit,
            chekAndGetFiltFls(dir, ext)
        )
    )

    const _getFilesAndOmit = R.curry( (dir, namesOmit) => R.without(
            namesOmit,
            chekAndGetFiles(dir)
        )
    )

    function isDir               (dir) { return _isDir(dir) }
    function existAndIsDir       (dir) { return _existAndIsDir(dir) }
    function conctDir            (dir, file) { return _conctDir(dir)(file) }
    function conctsDirs          (dir, files) { return _conctsDirs(dir)(files) }
    function isDirReadAgain      (dir) { return _isDirReadAgain(dir) }
    function getDeepFiles        (dir) { return _getDeepFiles(dir) }
    function conctsDirsIsFile    (dir, files) { return _conctsDirsIsFile(dir)(files) }
    function getFiles            (dir) { return _getFiles(dir) }
    function getFiltFiles        (ext, dir) { return _getFiltFiles (ext)(dir) }
    function getFilesAndOmit     (dir, omitFiles) { return _getFilesAndOmit(dir)(omitFiles) }
    function getFiltFilesAndOmit (ext, dir, omitFiles) { return _getFiltFilesAndOmit(ext)(dir)(omitFiles) }
    function chekAndGetFiles     (dir) { return _chekAndGetFiles(dir) }
    function chekAndGetFiltFls   (ext, dir) { return _chekAndGetFiltFls(ext, dir) }

    return {
        conctDir,
        conctsDirs,
        isDirReadAgain,
        getDeepFiles,
        conctsDirsIsFile,
        getFiles,
        getFiltFiles,
        getFilesAndOmit,
        getFiltFilesAndOmit,
        chekAndGetFiles,
        chekAndGetFiltFls
    }
})();

/* Usage */
// console.log('getDeepFiles: ', getDeepFiles('C:\\Users\\lapena\\Documents\\Test'))
// console.log('getFiles: ', getFiles('C:\\Users\\lapena\\Documents\\Test'))
// console.log('getFiltFls: ', getFiltFls(['.vis','.frm','.esp','.tbl','.rep','.dlg'],'C:\\Users\\lapena\\Documents\\Test'))
// console.log(chekAndGetFiles('../../Testing' ))
// console.log(getFiltFls(['.frm'],'../../Testing' ))