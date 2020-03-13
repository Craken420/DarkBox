const R = require('ramda')

const { getLatinTxt } = require('../Mix/fnFiles').fnFile

module.exports.toModule = (function () {

    const _nameToPublicFn = nameFn => `function ${nameFn} (txt) { return _${nameFn}(txt) }`

    const _namesToPublicFn = R.pipe(
        R.map(nameToPublicFn),
        R.join('\n')
    )

    const _joinNames = R.pipe(
        R.map(R.replace(/^/gm, '\t')),
        R.join(',\n')
    )

    const _getFnsKeysInPrivateFn = R.pipe(
        R.replace(/^(?=\w+(\s+|):)/gm, 'const __'),
        R.replace(/(?<=const(\s+|)\w+(\s+|)):/gm, ' = '),
    )

    const _addLowBraketInFnName = R.pipe(
        R.replace(/(?<=\bconst\b(\s+))(?=\w+)/g, '_')
    )

    const _getPrivatsFnsModule = R.curry((privFns, fns, retrn) => ''
        + 'module.exports.nameModule = (function () {'
        + '\n\n' + privFns
        + '\n\n' + fns
        + '\n\n' + 'return {\n'
        + retrn + '\n}\n})();'
    )

    const _getFnsNames = R.match(/(?<=\bconst\b(\s+))\w+/g)

    const _getFnsKeys = R.match(/\w+(?=(\s+|):)/g)

    const _makeModuleFnsPrivate = fnsString => {
        if ( R.test(/(?<=\bconst\b(\s+))\w+/g, fnsString) ) {
            return getPrivatsFnsModule(
                addLowBraketInFnName(fnsString),
                namesToPublicFn( getFnsNames(fnsString) ),
                joinNames( getFnsNames(fnsString) )
            )
        } else if ( R.test(/\w+(?=(\s+|):)/g, fnsString) ) {
            return getPrivatsFnsModule(
                getFnsKeysInPrivateFn(fnsString),
                namesToPublicFn( getFnsKeys(fnsString) ),
                joinNames( getFnsKeys(fnsString)  )
            )
        } else {
            return ''
        }
    }

    const _runFile = R.pipe(
        getLatinTxt,
        makeModuleFnsPrivate
    )

    function nameToPublicFn (txt) { return _nameToPublicFn(txt) }
    function namesToPublicFn (txt) { return _namesToPublicFn(txt) }
    function joinNames (txt) { return _joinNames(txt) }
    function getFnsKeysInPrivateFn (txt) { return _getFnsKeysInPrivateFn(txt) }
    function addLowBraketInFnName (txt) { return _addLowBraketInFnName(txt) }
    function getPrivatsFnsModule(privFns, fns, retrn) { return _getPrivatsFnsModule(privFns)(fns)(retrn) }
    function getFnsNames (txt) { return _getFnsNames(txt) }
    function getFnsKeys (txt) { return _getFnsKeys(txt) }
    function makeModuleFnsPrivate (txt) { return _makeModuleFnsPrivate(txt) }
    function runFile (file) { return _runFile(file) }

    return {
        nameToPublicFn,
        namesToPublicFn,
        joinNames,
        getFnsKeysInPrivateFn,
        addLowBraketInFnName,
        getPrivatsFnsModule,
        getFnsNames,
        getFnsKeys,
        makeModuleFnsPrivate,
        runFile
    }
})();