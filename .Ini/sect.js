/* They allow grouping related parameters. 
    For example: "Network parameters".
    [Red] // Section
    UsarProxy=1 // Values
*/

const { make } = require('../Rgx/make')
const { take } = require('../Rgx/take')
const { patt } = require('../Rgx/patterns')
const { adapt } = require('../Rgx/adapt')
const R = require('ramda')

const { fnFld } = require('./flds')
const { fnObj } = require('./objct')
const { fnFile } = require('../Mix/fnFiles')

// const { toOrigFls } = require('../newPath').newPath

module.exports.fnComp = (function () {
    const _nameFileInComp = (arrayComps) => {
        return arrayComps.map(x => {
            if (x) {
                if (take.intls.comp.head(x)) {
    
                    let nameFile = take.intls.comp.nameFile(
                        '[' + take.intls.comp.head(x).join('') + ']'
                    )
    
                    if (nameFile) return nameFile
    
                } else false
            } else {
                false
            }
        }).join(',').split(',')
    }

    const _cmpHead = txt => (patt.cmpHead.test(txt.replace(/^/, '\n'))) ? txt.replace(/^/, '\n').match(patt.cmpHead) : false
    
    const _getName = R.pipe(
        R.replace(/(?<=^\[).*?\//g, ''),
        cmpHead,
        R.join('')
    )
    
    const _delDeepEmpty = obj =>{
        for (key in obj) {
            (typeof(obj[key]) == 'string') ? (obj[key] == '') && delete obj[key] : (typeof(obj[key]) ==
    'object') && delDeepEmpty(obj[key])
        }
        return obj
    }
    
    const _cmpToObj = cmp => R.objOf( getName(cmp), fldsToObj(cmp) )

    const _toObj = R.pipe(
        R.map(cmpToObj),
        R.mergeAll
    )
    
    const _cmpsToTxt = R.pipe(
        R.map(R.toPairs),
        R.map(fldsToTxt),
        R.toPairs,
        R.map(R.join(']\n')),
        R.map(R.replace(/^/, '['))
    )
    
    const _delEmptyToTxt = R.pipe(
        delDeepEmpty,
        cmpsToTxt
    )

    const _fldsToObj = R.pipe(
        take.fldFull,
        R.map(R.split(/=/)),
        R.fromPairs
    )
    
    const _fldsToTxt = R.pipe(
        R.map(R.join('=')),
        R.join('\n')
    )
    
    
    const _cmpByName = R.curry( (nameComp, txt) => {
        // console.log('nameComp: ',nameComp)
        // console.log('rgx: ',make.cmpByNameNoAdapt(nameComp))
        // console.log('test: ',make.cmpByNameNoAdapt(nameComp).test(txt))
        // console.log('txt: ',txt)
        txt = txt.replace(/^\n+/gm, '\n')
        if (cmpByNameNoAdapt(nameComp).test(txt)) {
            return txt.match(cmpByNameNoAdapt(nameComp))
        } else {
            return nameComp
        }
        // return nameComp
    })
    
    const _getCmpsByName = R.curry( (cmps, txt) => cmps.map(cmp => {
        return cmpByName(getName(cmp), txt)
    }))
    
    const _cmpWithAllHeadToObj = cmp => R.objOf( cmpHead(cmp), fldsToObj(cmp) )
    
    const _mergCmpWithCmpInTxt = R.curry( (cmp, txt) => delEmptyToTxt(
            R.mergeDeepRight(
                cmpWithAllHeadToObj(cmpByName(cmpHead(cmp), txt).join('')),
                cmpWithAllHeadToObj(cmp)
            )
        )
    )
    
    const _cmpByNameNoAdapt = nameComp => new RegExp(`\\[\\b${nameComp}\\b\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`, `gm`)
    
    const _addCmpExst = R.curry( (exstCmp, txt) => {
        // console.log(mergCmpWithCmpInTxt(exstCmp, txt).join(''))
        return R.replace(
            cmpByNameNoAdapt(cmpHead(exstCmp)),
            mergCmpWithCmpInTxt(exstCmp, txt).join('') + '\n',
            txt
        )
    })
    
    const _toRgxHeadComp = nameComp => new RegExp(`^\\[\\b${nameComp}\\b\\]`, `gm`)
    const _toRgxHeadCmp = R.pipe(cmpHead, /*mix.adapt.toRegExp,*/ toRgxHeadComp)
    const _checkExstHeadCmpInTxt = R.curry( (comp, txt) => R.test( toRgxHeadCmp(comp), txt ))
    const _addCmpInexstInTxt = R.curry( (InxstCmp, txt) => {
        txt = txt + '\n' + InxstCmp + '\n'
        return txt
    })
    
    const _addCmp = R.curry( (comp, text) => {
        console.log(
            'cmpExist: ',
            checkExstHeadCmpInTxt(comp,text),
            'comp: \n',
            comp

        )
        if ( checkExstHeadCmpInTxt(comp,text) ) {
            text = addCmpExst(comp, text)
        }
        else {
            text = addCmpInexstInTxt(comp,text)
        }
        return text
    })

    const _getComponentsByNames = (arrayNames, txt) => {
        return arrayNames.map(x => {
            let olComp = take.intls.comp.byName(
                x,
                txt
            )
            if (olComp) {
                return olComp
            }
        })
    }

    const _rplacWithNewCmps = R.curry( (cmps, txt) => {
        R.forEach(cmp => {
                txt = R.replace(
                    make.cmpByName(getName(cmp)),
                    cmp + '\n',
                    txt
                )
            },
            cmps
        )
        return txt
    })

    const _checkInexstHeadCmpInTxt = R.complement(checkExstHeadCmpInTxt)

    const _cutByExstInOrig = file => R.zipObj(['path','exst','cmpInxst'],
        [
            file,
            getExstInOrigUnq(file),
            getInxst( getAllInPath(file) )( toOrigFls(file) ).join('\n')
        ]
    )

    const _delEmptFldsInTxt = R.pipe(
        take.cmpAll,
        fnObj.toObj,
        fnObj.delDeepEmpty,
        fnObj.cmpsToTxt,
        R.join('\n\n')
    )

    const _getAllInPath = R.pipe(
        fnFile.getLatinTxt,
        take.cmpAll
    )

    const _getExstInOrig = file => getExst( getAllInPath(file) )( toOrigFls(file ))

    const _getUniq = x => R.prepend( '[' + getName(x) + ']', fnFld.getUniq(x) ).join('\n')

    const _getExstInOrigUnq = R.pipe(
        getExstInOrig,
        R.map(getUniq),
    )

    const _getInxst = R.curry( (comps, file) => R.filter( cmp => checkInxstCmp(cmp, file), comps ) )
    const _hasComp = txt => patt.cmpAll.test(txt)
    const _mergOrgEsp = R.curry( (cmps, file) => delEmptyToTxt(R.mergeDeepRight(
            fnObj.toObj(
                R.unnest(
                    getCmpsByName( cmps, fnFile.gtLtnTxt( file ) )
                )
            ),
            fnObj.toObj(cmps)
        ))
    )

    const _checkExstCmp = R.curry( (comp, pathFile) => R.test( toRgxNmCmp(comp), fnFile.gtLtnTxt(pathFile) ))

    const _checkInxstCmp = R.complement(checkExstCmp)

    const _addCmpInexstInFile = R.curry( (InxstCmps, pathFile) => {
        fs.appendFileSync(
            'Data\\' + mix.cls.pthRoot(pathFile),
            '\n' + cleanTxtCmps(InxstCmps),
            'latin1'
        )
        return true
    })
    
    const _addCmpExstInFile = R.curry( (exstCmps, pathFile) => {
        fs.writeFileSync(
            'Data\\' + mix.cls.pthRoot(pathFile),
            rplacWithNewCmps(
                exstCmps,
                fnFile.gtLtnTxt(pathFile)
            ),
            'latin1'
        )
        return true
    })
    const _toRgxNmCmp = R.pipe(getName, adapt.toRegExp, make.toRgxNameComp)

    const _txtCmpsToUniq = R.pipe(
        take.cmpAll,
        R.map(getUniq),
        R.join('\n\n')
    )

    const _cleanTxtCmps = R.pipe(
        txtCmpsToUniq,
        delEmptFldsInTxt
    )

    function getExstInOrig (file) { return _getExstInOrig(file) }
    function getUniq (cmps) { return _getUniq(cmps) }
    function getExstInOrigUnq (cmps) { return _getExstInOrigUnq(cmps) }
    function getInxst (comps, file)  { return _getInxst(comps)(file) }
    function hasComp (txt) { return _hasComp(txt) }
    function mergOrgEsp (comps, file) { return _mergOrgEsp(comps, file) }
    function checkExstCmp (comp, pathFile) { return _checkExstCmp(comp, pathFile) }
    function checkInxstCmp (comp, pathFile) { return _checkInxstCmp(comp, pathFile) }
    function addCmpInexstInFile (InxstCmps, pathFile) { return _addCmpInexstInFile(InxstCmps, pathFile) }
    function addCmpInexstInTxt (InxstCmps, pathFile) { return _addCmpInexstInTxt(InxstCmps, pathFile) }
    function addCmpExstInFile (exstCmps, pathFile) { return _addCmpExstInFile(exstCmps, pathFile) }
    function toRgxNmCmp (cmp) { return _toRgxNmCmp(cmp) }
    function txtCmpsToUniq (txt) { return _txtCmpsToUniq(txt) }
    function cleanTxtCmps (txt) { return _cleanTxtCmps(txt) }
    function delEmptFldsInTxt (cmps) { return _delEmptFldsInTxt(cmps) }
    function rplacWithNewCmps (cmps, txt) { return _rplacWithNewCmps(cmps)(txt) }
    function cmpHead (comp) { return _cmpHead(comp) }
    function getName (comp) { return _getName(comp) }
    function delDeepEmpty (obj) { return _delDeepEmpty(obj) }
    function cmpToObj (comp) { return _cmpToObj(comp) }
    function toObj (comps) { return _toObj(comps) }
    function cmpsToTxt (comps) { return _cmpsToTxt(comps) }
    function delEmptyToTxt (comps) { return _delEmptyToTxt(comps) }
    function fldsToTxt (fields) { return _fldsToTxt(fields) }
    function cmpByName (nameComp, txt) { return _cmpByName(nameComp)(txt) }
    function getCmpsByName (cmps, txt) { return _getCmpsByName(cmps)(txt) }
    function cmpWithAllHeadToObj (cmp) { return _cmpWithAllHeadToObj(cmp) }
    function mergCmpWithCmpInTxt (cmp, txt) { return _mergCmpWithCmpInTxt(cmp)(txt) }
    function cmpByNameNoAdapt (nameComp) { return _cmpByNameNoAdapt(nameComp) }
    function addCmpExst (exstCmp, txt) { return _addCmpExst(exstCmp)(txt) }
    function toRgxHeadComp (nameComp) { return _toRgxHeadComp(nameComp) }
    function toRgxHeadCmp (txt) { return _toRgxHeadCmp(txt) }
    function checkExstHeadCmpInTxt (comp, txt) { return _checkExstHeadCmpInTxt(comp)(txt) }
    function addCmp (comp, text) { return _addCmp(comp)(text) }
    function fldsToObj (fields) { return _fldsToObj(fields) }
    function checkInexstHeadCmpInTxt (cmps, txt) { return _checkInexstHeadCmpInTxt(cmps)(txt) }
    function cutByExstInOrig (file) { return _cutByExstInOrig(file) }
    function getAllInPath (file) { return _getAllInPath(file) }
    function getComponentsByNames (arrayNames, txt) { return _getComponentsByNames(arrayNames, txt) }
    function nameFileInComp(arrayComps)  { return _nameFileInComp(arrayComps) }
    return {
        getAllInPath,
        nameFileInComp,
        getComponentsByNames,
        addCmpInexstInFile,
        addCmpInexstInTxt,
        delEmptFldsInTxt,
        cutByExstInOrig,
        rplacWithNewCmps,
        cmpHead,
        getName,
        delDeepEmpty,
        cmpToObj,
        toObj,
        cmpsToTxt,
        delEmptyToTxt,
        fldsToTxt,
        cmpByName,
        getCmpsByName,
        cmpWithAllHeadToObj,
        mergCmpWithCmpInTxt,
        cmpByNameNoAdapt,
        addCmpExst,
        addCmpExstInFile,
        toRgxHeadComp,
        toRgxHeadCmp,
        checkExstHeadCmpInTxt,
        checkInexstHeadCmpInTxt,
        addCmp,
        fldsToObj,
        getExstInOrig,
        getUniq,
        getExstInOrigUnq,
        getInxst,
        hasComp,
        mergOrgEsp,
        checkExstCmp,
        checkInxstCmp,
        addCmpExst,
        toRgxNmCmp,
        txtCmpsToUniq,
        cleanTxtCmps
    }
})();