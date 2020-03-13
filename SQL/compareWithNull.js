const fs = require('fs')
const path = require('path')
const R = require('ramda')

const { DrkBx } = require('../index')

const hasCaseCmprNull = R.test( DrkBx.patt.sqlCaseCmprNull )

const hasIfCmprNull = R.test( DrkBx.make.sqlCmprNullIn('if') )

const hasAndCmprNull = R.test( DrkBx.make.sqlCmprNullIn('and') )

const hasOrCmprNull = R.test( DrkBx.make.sqlCmprNullIn('or') )

const hasWhereCmprNull = R.test( DrkBx.make.sqlCmprNullIn('where') )

const anyCondPass = R.anyPass([
    hasIfCmprNull,
    hasAndCmprNull,
    hasOrCmprNull,
    hasWhereCmprNull,
    hasCaseCmprNull
])

const getLine = R.pipe(
    R.split(/(\r\n|\r)/g),
    R.filter( line => !R.test(/\r\n/g, line) ),
    R.mapObjIndexed(anyCondPass),
    R.filter(Boolean),
    R.keys,
    R.map(R.inc)
)

const anyHasIsNull = txt => anyCondPass([txt, txt, txt, txt, txt])


const getIndexOfComprIsNull = R.curry( (coding, file) => {
    if ( DrkBx.file.existAndIsFile(file) ) { 
        if ( anyHasIsNull( DrkBx.file.recode(coding, file) ) ) {
            let lines = getLine( DrkBx.file.recode(coding, file) )
            if ( lines.length != 0 || lines ) {
                return {
                    'File': path.basename(file),
                    'Lines': lines,
                    'Status' : 'Geted'
                }
            } else return false
        } else 
        return false
    } else return false
})

const toIsNull = R.curry( (coding, file) => {
    if ( DrkBx.file.existAndIsFile(file) ) {
        let hasIsNull = anyHasIsNull( DrkBx.file.recode(coding, file) )
        if (hasIsNull) {
            fs.writeFileSync(
                'Data\\' + path.basename(file),
                DrkBx.change.toIsNull( DrkBx.file.recode(coding, file) ),
                coding
            )
            return R.merge( getInFile(file), {'Status': 'Edited' } )
        } else {
            return false
        }
    } else {
        return false
    }
})

/*--------------------------------------------------------------------------------------
OPERACIÓN CON ARCHIVOS
----------------------------------------------------------------------------------------*/

const getInFile = file => {
    console.log('Proccess: ', path.basename(file) )
    if ( path.extname(file) == '.sql' ) {
        // console.log('to return :\n',getIndexOfComprIsNull('utf16le')(file),'\n---------end')
        if (
            getIndexOfComprIsNull('utf16le')(file)
        ) return getIndexOfComprIsNull('utf16le')(file)
        else return false
    }
    else {
        if (getIndexOfComprIsNull('Latin1')(file)) return getIndexOfComprIsNull('Latin1')(file)
        else return false
    }
}

const getInTheseFiles = R.pipe(
    R.map(getInFile),
    R.filter(Boolean)
)

const getInDir = R.pipe(
    DrkBx.file.getFiltFls,
    getInTheseFiles
)

const replaceInFile = file => {
    console.log('Proccess: ', path.basename(file) )
    if ( path.extname(file) == '.sql' ) {
        if (
            toIsNull('utf16le')(file)
        ) return toIsNull('utf16le')(file)
        else return false
    }
    else {
        if (toIsNull('Latin1')(file)) return toIsNull('Latin1')(file)
        else return false
    }
}

const replaceInTheseFiles = R.pipe(
    R.map(replaceInFile),
    R.filter(Boolean)
)

const replaceInDir = R.pipe(
    DrkBx.file.getFiltFls,
    replaceInTheseFiles
)

module.exports.comprWithNull = {
    getInFile: getInFile,
    getInTheseFiles: getInTheseFiles,
    getInDir: getInDir,
    replaceInFile: replaceInFile,
    replaceInTheseFiles: replaceInTheseFiles,
    replaceInDir: replaceInDir
}