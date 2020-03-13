const R = require('ramda')

const { patt } = require('./patterns')
const { add } = require('./add')
/*
 Glosary:
    pth: path
*/

module.exports.cls = (function () {
    const _ampersand = R.replace(/&/g, '')

    const _iniEndSpace = R.pipe( R.split(/\r\n|\r/g), R.map(R.trim), R.join('\n') )

    const _emptyLines = R.pipe( R.split(/\r\n|\r|\n/g), R.filter(Boolean), R.join('\n') )

    const _multiSpaceToOne = R.pipe(
        R.split(/\r\n|\r|\n/g),
        R.map(R.replace(/\s+/g, ' ')),
        R.join('\n')
    )

    const _tab = R.replace(/\t+/g, '')

    /* Path */
    const _pathRoot = txt => txt.replace(patt.pathRoot, '')

    const _pathAllUntlExt = txt => txt.replace(patt.pathUntilExt, '')


    /* Intelisis */
    const _intlsComments = R.replace(patt.intlsComments, '')

    const _intlsAftrAbbrvitObj = txt => txt.replace(patt.aftrAbbrtObj, '')

    const _intlsCmpOmitHead = txt => txt.replace(patt.cmpOmitHead, '')
    
    /* SQL */
    const _ansis = R.replace(patt.ansis, '')

    const _sqlLineComments = R.replace(patt.sqlLineComments, '')

    const _sqlMultiLineComments = function clsMultiLineCommentsSql (txt) {
        txt = txt.replace(patt.sqlMultiLineComments, '')
        if ( patt.sqlMultiLineComments.test(txt) ) {
            return clsMultiLineCommentsSql(txt)
        } else {
            return txt
        }
    }

    const _withNo = R.replace(patt.withNo, ' ')

    const _cmpsOutSide = (nameFileInHead, txt) => {
        if (make.cmpOutSide(nameFileInHead).test(txt)) {
            return txt.replace(make.cmpOutSide(nameFileInHead), '')
        } else {
            return txt
        }
    }
    const _outSide = (nameFileInHead, txt) => {
        if (make.outSide(nameFileInHead).test(txt)) {
            return txt.replace(make.outSide(nameFileInHead), '')
        } else {
            return txt
        }
    }

    const _aftrAbbrvitObj = txt => txt.replace(patt.aftrAbbrtObj, '')
    const _cmpOmitHead = txt => txt.replace(patt.cmpOmitHead, '')

    const _cleanTxt = R.pipe(
        ansis,
        withNo,
        sqlMultiLineComments,
        sqlLineComments,
        tab,
        iniEndSpace,
        multiSpaceToOne,
        emptyLines,
        add.cmpEnterInHead,
        R.toLower
    )

    function ampersand (txt) { return _ampersand(txt) }
    function iniEndSpace (txt) { return _iniEndSpace(txt) }
    function emptyLines (txt) { return _emptyLines(txt) }
    function multiSpaceToOne (txt) { return _multiSpaceToOne(txt) }
    function tab (txt) { return _tab(txt) }
    function pathRoot (txt) { return _pathRoot(txt) }
    function pathAllUntlExt (txt) { return _pathAllUntlExt(txt) }
    function intlsComments (txt) { return _intlsComments(txt) }
    function intlsAftrAbbrvitObj (txt) { return _intlsAftrAbbrvitObj(txt) }
    function intlsCmpOmitHead (txt) { return _intlsCmpOmitHead(txt) }
    function ansis (txt) { return _ansis(txt) }
    function sqlLineComments (txt) { return _sqlLineComments(txt) }
    function sqlMultiLineComments (txt) { return _sqlMultiLineComments(txt) }
    function withNo (txt) { return _withNo(txt) }
    function cmpsOutSide (txt) { return _cmpsOutSide(txt) }
    function outSide (txt) { return _outSide(txt) }
    function aftrAbbrvitObj (txt) { return _aftrAbbrvitObj(txt) }
    function cmpOmitHead (txt) { return _cmpOmitHead(txt) }
    function cleanTxt (txt) { return _cleanTxt(txt) }
    
    return {
        ampersand,
        iniEndSpace,
        emptyLines,
        multiSpaceToOne,
        tab,
        pathRoot,
        pathAllUntlExt,
        intlsComments,
        intlsAftrAbbrvitObj,
        intlsCmpOmitHead,
        ansis,
        sqlLineComments,
        sqlMultiLineComments,
        withNo,
        cmpsOutSide,
        outSide,
        aftrAbbrvitObj,
        cmpOmitHead,
        cleanTxt
    }
})();