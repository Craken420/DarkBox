const { patt } = require('./patterns')

const R = require('ramda')

module.exports.take = (function () {
    const _expresionElseWizardInSituacion = R.match(patt.expresionElseWizardInSituacion)
    const _abbrtObjBtwnLowScripts = txt => (patt.abbrtObjBtwnLowScripts.test(txt)) ? txt.match(patt.abbrtObjBtwnLowScripts) : false
    const _bfrAbbrtObj = txt => {
        if (patt.bfrAbbrtObj.test(txt)) {
            return txt.match(patt.bfrAbbrtObj)
        } else {
            return false
        }
    }
    const _cmpByName = R.curry((nameComp, txt) => {
        // console.log('nameComp: ',nameComp)
        // console.log('rgx: ',make.cmpByName(nameComp))
        // console.log('test: ',make.cmpByName(nameComp).test(txt))
        // console.log('txt: ',txt)
        // txt = txt.replace(/^\n+/gm, '\n')
        if (make.cmpByName(nameComp).test(txt)) {
            
            return txt.match(make.cmpByName(nameComp))
        } else {
            false
        }
    })
    const _cmpByNameFile = R.curry((nameComp, txt) => {
        if (make.cmpByNameFile(nameComp).test(txt)) {
            return txt.match(make.cmpByNameFile(nameComp))
        } else {
            false
        }
    })
    const _cmpHead = txt => (patt.cmpHead.test(txt.replace(/^/, '\n'))) ? txt.replace(/^/, '\n').match(patt.cmpHead) : false
    const _cmpNameFile = txt => patt.cmpNameFile.test(txt) && txt.match(patt.cmpNameFile)
    const _cmpOutSide = R.curry((nameComp, txt) => {
        if (make.cmpOutSide(nameComp).test(txt)) {
            return txt.match(make.cmpOutSide(nameComp))
        } else {
            return false
        }
    })
    const _cmpAll = txt =>(patt.cmpAll.test(txt)) ? txt.match(patt.cmpAll) : false
    
    
    const _fldContnt = R.curry((field, txt) => {
        if (make.fldContnt(field).test(txt)) {
            return txt.match(make.fldContnt(field)).join('')
        }
    })

    const _fldFull = txt => (patt.fldFull.test(txt)) ? txt.match(patt.fldFull) : false
    const _fldName = txt => (patt.fldName.test(txt)) ? txt.match(patt.fldName) : false

    function expresionElseWizardInSituacion (txt) { return _expresionElseWizardInSituacion(txt) }
    function abbrtObjBtwnLowScripts (txt) { return _abbrtObjBtwnLowScripts(txt) }
    function bfrAbbrtObj (txt) { return _bfrAbbrtObj(txt) }
    function cmpByName (nameComp, txt) { return _cmpByName(nameComp)(txt) }
    function cmpByNameFile (nameComp, txt) { return _cmpByNameFile(nameComp)(txt) }
    function cmpHead (txt) { return _cmpHead(txt) }
    function cmpNameFile (txt) { return _cmpNameFile(txt) }
    function cmpOutSide (nameComp, txt) { return _cmpOutSide(nameComp)(txt) }
    function cmpAll (txt) { return _cmpAll(txt) }
    function fldContnt (field, txt) { return _fldContnt(field)(txt) }
    function fldFull (txt) { return _fldFull(txt) }
    function fldName (txt) { return _fldName(txt) }

    return {
        expresionElseWizardInSituacion,
        abbrtObjBtwnLowScripts,
        bfrAbbrtObj,
        cmpByName,
        cmpByNameFile,
        cmpHead,
        cmpNameFile,
        cmpOutSide,
        cmpAll,
        fldContnt,
        fldFull,
        fldName
    }
})();
