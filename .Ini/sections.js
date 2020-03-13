/* They allow grouping related parameters. 
    For example: "Network parameters".
    [Red] // Section
    UsarProxy=1 // Values
*/

const { DrkBx } = require('../index')

module.exports.iniSect = (function () {
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

    function nameFileInComp (file) { return _nameFileInComp(file) }
    return {
        nameFileInComp,
    }
})();