const { patt } = require('../Rgx/patterns')
const { cls } = require('../Rgx/cls')

// exports.espToMavi = pathFile => {
//     return mix.rgx.change. change.mix.lastPointToLowScript(
//         pathFile.replace(rgx.paths.ext, cls.paths.allUntilExt(pathFile).toUpperCase())
//     ) + '_MAVI.esp'
// }

const maviToEsp = pathFile => {

    let nameFile = pathFile.replace(/.*\\/,'')
    // console.log(pathFile)
    if (patt.abbrtObjBtwnLowScripts.test(nameFile)){

        let newPath = mix.change.lastLowScriptToPoint(
            cls.aftrAbbrvitObj(
                mix.cls.pthExt(
                    nameFile
                )
            )
        )

        return newPath.replace(mix.patt.pthExt, mix.cls.pthAllUntlExt(newPath).toLowerCase())

    } else {
        return mix.cls.pthRoot(pathFile).replace(/(\_|\.).*/g, '')
    }
}

const toOrigFls = pathFile => 'c:\\Users\\lapena\\Documents\\Luis Angel\\Sección Mavi\\'
    + 'Intelisis\\Intelisis5000\\Codigo Original\\'
    + maviToEsp(pathFile)

module.exports.newPath = {
    maviToEsp: maviToEsp,
    toOrigFls: toOrigFls
}