const fs = require('fs')
const path = require('path')
const R = require('ramda')

const { patt } = require('../Rgx/patterns')



// const hasComps = R.test(/^\[.*?\]$((\n|\r)(?!(\n|)^\[.+?\]$).*?$)+/gm)

// const runDir = R.pipe(
//     DrkBx.dir.getFiltFls,
//     omitFls,
//     runThese
// )

// const runTheseFiles = R.pipe(
    // R.filter(filtConvention),
    // R.filter(file => hasOutSideComps( toEsp(file) )( DrkBx.mix.fls.gtLtnTxt(file) ) ),
    // R.map(pcFile)
// )

module.exports.fixEsp = (function () {
    
    const hasObjBtweenLowBrakets = R.test(/_(dlg|frm|rep|tbl|vis)(_|\b)/gi)

    const letTheName = R.pipe(
        path.parse,
        R.prop('name'),
        R.replace(/_MAVI/gi, '')
    )

    const convertToOrig = R.pipe(
        letTheName,
        R.replace(/_(?=(dlg|frm|rep|tbl|vis)(_|\b))/gim, '.'),
        R.replace(patt.pathExt, R.toLower)
    )

    const pathToOrig = file => ( hasObjBtweenLowBrakets(file) ) ? convertToOrig(file) : null

    const adaptRgx = R.pipe(
        R.replace(/\./g, '\\.'),
        R.replace(/\(/g, '\\('),
        R.replace(/\)/g, '\\)'),
        R.replace(/\[/g, '\\['),
        R.replace(/\]/g, '\\]'),
        R.replace(/\*/g, '\\*'),
        R.replace(/\+/g, '\\+')
    )

    const rgxWrongCompsByNameFile = nameFile => new RegExp(`^\\[(?!((\\b${adaptRgx(nameFile)}\\/))|\\bAcciones\\b).*?\\]$((\\n|\\r)(?!(\\n|)^\\[.+?\\]$).*?$)+`, `gim`)
    const hasWrongComps = (nameFile, txt) => R.test(rgxWrongCompsByNameFile(nameFile), txt)
    // const getWrongCompsByNameFile = file => ( pathToOrig(file) ) ? R.match( rgxWrongCompsByNameFile( pathToOrig(file) ), DrkBx.files.getLatinTxt(file) ) : null
    // const getWrongComps = file => ( hasObjBtweenLowBrakets(file) ) ? getWrongCompsByNameFile(file) : DrkBx.take.cmpAll(file)


    const runFile = file => {
        if ( hasObjBtweenLowBrakets(file) ) {
        console.log(file)
        }

        // if ( hasWrongComp(file) ) {
            // return file
        //     return getWrongComps(file)
        // } else return { file: path.basename(file), status: 'Haven´t Wrong Comps' }
    }

    return {
        runFile
    }
})();