const chardet   = require('chardet')
const fs        = require('fs')
const iconvlite = require('iconv-lite')

module.exports.fnComp = (function () {
    const _changeCodignFile = (pathFile, wishCoding) => {
        return iconvlite.decode(fs.readFileSync(pathFile), wishCoding)
    }

    const _detectCodingFile = pathFile => chardet.detectFileSync(pathFile)

    const _getTxtInOriginCoding = pathFile => {
        return iconvlite.decode(
            fs.readFileSync(pathFile),
            chardet.detectFileSync(pathFile)
        )
    }

    function changeCodignFile (array) { return _changeCodignFile(array) }
    function detectCodingFile (array) { return _detectCodingFile(array) }
    function getTxtInOriginCoding (array) { return _getTxtInOriginCoding(array) }

    return {
        changeCodignFile,
        detectCodingFile,
        getTxtInOriginCoding
    }
})();
