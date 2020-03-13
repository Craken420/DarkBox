const R = require('ramda')
const { take } = require('../Rgx/take')

const addField = (nameCmp, newfields, toFile) => {

    let olderComp = take.intls.comp.byName(
        nameCmp.join(''),
        code.getTxtInOriginCoding(toFile).replace(/^\n+/gm, '\n')
    )

    if (olderComp) {

        olderComp =  duplex.del(olderComp)

        if (olderComp.length != 0) {
            return isNewOrExist(newfields, olderComp[0])
        }
    }
}

const isNewOrExist = (field, txt) => {
    let nameField = take.intls.field.name(field)
    
    if (nameField) {
        if (new RegExp (`^${nameField}=`, `m`).test(txt)) {
            return true
        } else {
            return false
        }
    }
}

const getUniq = R.pipe(
    take.fldFull,
    R.reverse,
    R.map(R.split(/=/)),
    R.fromPairs,
    // mix.obj.delDeepEmpty,
    R.toPairs,
    R.map(R.join('=')),
    R.reverse
)

module.exports.fnFld = {
    isNewOrExist: isNewOrExist,
    getUniq: getUniq,
    addField: addField
}