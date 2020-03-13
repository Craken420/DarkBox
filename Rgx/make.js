
module.exports.make = (function () {
    const _intlsCmpByName = nameComp => new RegExp(`\\[\\b${adapt.toRegExp(nameComp)}\\b\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`, `gm`)
    const _cmpByNameNoAdapt = nameComp => new RegExp(`\\[\\b${nameComp}\\b\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`, `gm`)
    const _intlscmpByNameFile = nameFile => new RegExp(`^\\[${adapt.toRegExp(nameFile)}\\/.*?\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`, `gm`)
    const _intlscmpExist = nameComp => new RegExp(`^\\[${adapt.toRegExp(nameComp.join(''))}\\]`, `gm`)
    const _intlscmpInTheEnd = nameComp => new RegExp (`(?<=\\[${nameComp}\\](\\r\\n(?!^\\[.+?\\]).*?$)+)`,`m`)
    const _intlscmpOutSide = nameComp => new RegExp(`\\[(?!(\\b${adapt.toRegExp(nameComp)}\\b)).*?\\/.*?\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`, `gim`)
    // outSide: nameComp => new RegExp(`\\[(?!(\\b${adapt.toRegExp(nameComp)}\\b|Acciones)).*?\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`, `gm`),
    const _intlsfldContnt = field => new RegExp(`(?<=^${adapt.toRegExp(field)}\=).*?(?=(\\r|\\n|$))`, `gm`)
    const _intlstoRgxNameComp = nameComp => new RegExp(`^\\[\\b${nameComp}\\b\\]`, `gm`)
    const _toRgxHeadComp = nameComp => new RegExp(`^\\[\\b${nameComp}\\b\\]`, `gm`)
    const _sqlCmprNullIn = cond => new RegExp(
        `\\b${cond}\\b[\\s\\n]*?[\\w.\\(\\)_@-]*?[\\s\\n]*?(=|<>|>|<|>=|<=|!=|!<|!>)[\\s\\n]*?\\bNULL\\b`,
        `gi`
    )

    const _sqlSymbolCmprNullIn = cond => new RegExp(
        `(?<=\\b${cond}\\b[\\s\\n]*?[\\w.\\(\\)_@-]*?[\\s\\n]*?)(=|<>|>|<|>=|<=|!=|!<|!>)[\\s\\n]*?\\bNULL\\b`,
        `gi`
    )


    function toRgxHeadComp (nameComp) { return _toRgxHeadComp(nameComp) }
    function cmpByNameNoAdapt (nameComp) { return _cmpByNameNoAdapt(nameComp) }
    function sqlCmprNullIn (cond) { return _sqlCmprNullIn(cond) }
    function sqlSymbolCmprNullIn (cond) { return _sqlSymbolCmprNullIn(cond) }

    function intlsCmpByName (comp) { return _intlsCmpByName(comp) }
    function intlscmpByNameFile (comp) { return _intlscmpByNameFile(comp) }
    function intlscmpExist (comp) { return _intlscmpExist(comp) }
    function intlscmpInTheEnd (comp) { return _intlscmpInTheEnd(comp) }
    function intlscmpOutSide (comp) { return _intlscmpOutSide(comp) }
    function intlsfldContnt (comp) { return _intlsfldContnt(comp) }
    function intlstoRgxNameComp (comp) { return _intlstoRgxNameComp(comp) }

    return {
        cmpByNameNoAdapt,
        toRgxHeadComp,
        sqlCmprNullIn,
        sqlSymbolCmprNullIn,
        intlsCmpByName, 
        intlscmpByNameFile,
        intlscmpExist,  
        intlscmpInTheEnd, 
        intlscmpOutSide, 
        intlsfldContnt,
        intlstoRgxNameComp 
    }
})();
