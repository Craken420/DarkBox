const { patt } = require('./patterns')
const R = require('ramda')

module.exports.add = (function () {
    /* Intelisis */
    const _cmpEnterInHead = R.replace(patt.cmpBraketOfHead, '\n[')
    const _fldTabInField = R.replace(patt.fldIniLineOfField, '\t' )
    const _updtVisInExpresionWizard = R.replace(patt.btweenExpresionAndWizard, '  ActualizarVista <BR> ')
    const _addCmp = R.curry( (comp, text) => {
        if (DrkBx.intls.fnCmp.checkExstHeadCmpInTxt(comp,text)) {
            text = DrkBx.intls.fnCmp.addCmpExst(comp, text)
        }
        else {
            text = DrkBx.intls.fnCmp.addCmpInexst(comp,text)
        }
        return text
    })

    function cmpEnterInHead(txt) { return _cmpEnterInHead(txt) }
    function fldTabInField(txt) { return _fldTabInField(txt) }
    function updtVisInExpresionWizard(txt) { return _updtVisInExpresionWizard(txt) }
    function addCmp(comp, text) { return _addCmp(comp)(text) }

    return {
        cmpEnterInHead,
        fldTabInField,
        updtVisInExpresionWizard,
        addCmp 
    }
})();