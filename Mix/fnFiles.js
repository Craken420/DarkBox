const R = require('ramda')

/* Paths */
const chardet   = require('chardet')
const fs        = require('fs')
const iconvlite = require('iconv-lite')
const path = require('path')
const XLSX = require('xlsx')

const { change } = require('../Rgx/change')
const { fnDir } = require('./fnDir')

module.exports.fnFile = (function () {

    const _isFl = file => fs.statSync(file).isFile()

    const _existAndIsFile = R.both(fs.existsSync, isFl)

    const _recode = R.curry( (cod, file) => iconvlite.decode( fs.readFileSync(file), cod) )

    const _getTxtInOrgnCod = file => recode( file, chardet.detectFileSync(file) )

    const _getLatinTxt = file => fs.readFileSync(file, 'Latin1')

    const _chekAndGetLatinTxt = R.both(existAndIsFile, getLatinTxt)

    const _toEspWithDir = R.curry( (dir, file) => fnDir.conctDir(dir, change.pathOrigToEsp(file) ) )

    const _checkAndCreate = file => {
        if (fs.existsSync(file)) {
            return {
                file: file,
                status: 'Exist'
            }
         } else {
            fs.writeFileSync(file, '', 'latin1')
            return {
                file: file,
                status: 'Created'
            }
        }
    }

    const _toEspDirCheckAndCreate = R.curry( 
        (dir, file) => checkAndCreate( toEspWithDir(dir, file) ) )

    const _getPathsFiles = pathDir => fs.readdirSync(pathDir).map( x => path.resolve(pathDir, x) )
    
    const _filterFiles = R.curry( 
        (ext, files) => files.filter( x => ext.indexOf( 
            path.extname(x) ) > -1 && fs.statSync(x).isFile() ) )

    const _getFiltFls = R.curry( (ext, files) => filterFiles( ext, getPathsFiles(files) ) )

    const _getExcelInObj = R.curry((file, numSheet) => {
        let workbook = XLSX.readFile(file)
        let sheet_name_list = workbook.SheetNames
        if ( Array.isArray(numSheet) ) {
            return  R.map( sheet => {
                        return XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[sheet]])
                    }, numSheet ) 
        } else if ( typeof(numSheet) == 'number') {
            return XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[numSheet]])    
        } else return null
    })

    const _deleteEmptyFile = (pathFile) => {
        if(!fs.readFileSync(pathFile).toString()) {
            console.log('Delete: ', pathFile.replace(/.*\\|.*\//g, ''))
            fs.unlinkSync(pathFile)
            return true
        } else {
            false
        }
    }

    function deleteEmptyFile (file) { return _deleteEmptyFile(file) }
    function getExcelInObj (file, numSheet) { return _getExcelInObj(file)(numSheet) }
    function getPathsFiles (pathDir)        { return _getPathsFiles(pathDir) }
    function filterFiles   (ext, files)     { return _filterFiles(ext)(files) }
    function getFiltFls    (ext, files)     { return _getFiltFls(ext)(files) }
    function chekAndGetLatinTxt (file)      { return _chekAndGetLatinTxt(file) }
    function existAndIsFile     (file)      { return _existAndIsFile(file) }
    function getLatinTxt        (file)      { return _getLatinTxt(file) }
    function getTxtInOrgnCod    (file)      { return _getTxtInOrgnCod(file) }
    function isFl               (file)      { return _isFl(file) }
    function recode             (cod, file) { return _recode(cod)(file) }
    function toEspWithDir       (dir, file) { return _toEspWithDir(dir)(file) }
    function checkAndCreate     (file)      { return _checkAndCreate(file) }
    function toEspDirCheckAndCreate (dir, file) { return _toEspDirCheckAndCreate(dir)(file) }

    return {
        chekAndGetLatinTxt,
        deleteEmptyFile,
        existAndIsFile,
        getLatinTxt,
        getTxtInOrgnCod,
        isFl,
        recode,
        toEspWithDir,
        checkAndCreate,
        toEspDirCheckAndCreate,
        getPathsFiles,
        filterFiles,
        getFiltFls,
        getExcelInObj
    }
})();

/* Usage */
// console.log(isFl('C:\\Users\\lapena\\Documents\\Test\\archivos.frm'))
// console.log(existAndIsFile('C:\\Users\\lapena\\Documents\\Test\\archivos.frm'))
// console.log(chekAndGetLatinTxt('C:\\Users\\lapena\\Documents\\Test\\archivos.frm'))
