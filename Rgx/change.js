const R = require('ramda')
const { patt } = require('./patterns')
const { make } = require('./make')
const { cls } = require('./cls')
const path = require('path')

module.exports.change = (function () {

    const _toIsNull = R.pipe(
        R.replace(
            make.sqlSymbolCmprNullIn('if'),
            ' IS NULL '
        ),
        R.replace(
            make.sqlSymbolCmprNullIn('and'),
            ' IS NULL '
        ),
        R.replace(
            make.sqlSymbolCmprNullIn('or'),
            ' IS NULL '
        ),
        R.replace(
            make.sqlSymbolCmprNullIn('where'),
            ' IS NULL '
        ),
        R.replace(
            patt.sqlSymbolCmprNullInCase,
            ' IS NULL '
        )
    )

    const _lastLowScriptToPoint =  txt => txt.replace(patt.lastLowScript, '.')

    const _lastPointToLowScript = txt => txt.replace(patt.lastPoint, '_')

    const _pathEspToOrig = R.pipe(
        path.parse,
        R.prop('name'),
        R.replace(/_MAVI/gi, ''),
        lastLowScriptToPoint,
        R.replace(patt.pathExt, R.toLower)
    )

    const _pthAllUntlExt = txt => txt.replace(patt.pathUntilExt, '')

    const _extToUpperWithLowBraket = R.pipe(
        path.extname,
        R.toUpper,
        R.replace(/./, '_')
    )

    const _pathOrigToEsp = pathFile => R.prop('name',path.parse(pathFile))
        + extToUpperWithLowBraket(pathFile)
        + '_MAVI.esp'

    function extToUpperWithLowBraket (pathFile) { return _extToUpperWithLowBraket(pathFile) }

    function toIsNull (txt) { return _toIsNull(txt) }

    function lastLowScriptToPoint (txt) { return _lastLowScriptToPoint(txt) }

    function lastPointToLowScript (txt) { return _lastPointToLowScript(txt) }
    
    function pathEspToOrig (pathFile) { return _pathEspToOrig(pathFile) }

    function pathOrigToEsp (pathFile) { return _pathOrigToEsp(pathFile) }

    function pathAllUntlExt (pathFile) { return _pthAllUntlExt(pathFile) }

    return {
        toIsNull,
        pathEspToOrig,
        pathOrigToEsp,
        lastLowScriptToPoint,
        lastPointToLowScript,
        pathAllUntlExt,
        extToUpperWithLowBraket
    }
})();
