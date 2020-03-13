const R = require('ramda')
const fs = require('fs')

const { DrkBx } = require('../../../DarkBox/index')

const _getLine = R.curry( 
    (pFile, noSheet) => ( Array.isArray(noSheet) ) ? R.map( sheet => DrkBx.objs.objToSqlInserLine(
                                            DrkBx.file.getExcelInObj(pFile, sheet) 
                            ), noSheet ) 
                        : ( typeof(noSheet) == 'number') 
                            ? DrkBx.objs.objToSqlInserLine(
                                DrkBx.file.getExcelInObj(pFile, noSheet) ) 
                            : false
)

/* To save the result in a report */                           
const _getReport = R.curry( (pFile, noSheet) => {
    let result;
    result = getLine(pFile, noSheet)

    if ( Array.isArray(result) ) fs.writeFileSync('Data\\Report-Inserts.txt', 
                                    'INSERTS:\n\n' + R.join('\n\n', result), 'Latin1')
    else fs.writeFileSync('Data\\Report-Inserts.txt', 
                          'INSERTS:\n\n' + result, 'Latin1')
    return result;
})

/*--------------------------------------------------------------------------------------
    Privates function simulation
----------------------------------------------------------------------------------------*/
function getLine (pFile, noSheet) { return _getLine(pFile)(noSheet)}
function getReport (pFile, noSheet) { return _getReport(pFile)(noSheet) }

module.exports.excelToSQLInsertLine = {
    getLine,
    getReport
}