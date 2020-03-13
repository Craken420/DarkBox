const R = require('ramda')
const path = require('path')
const { DrkBx } = require('../../../../../USB/Desarrollo TI/Programación/Code/HerramientasMavi/ProyectosGit/Refactor/MergeEsp/DarkBox')

// const rootData = './Data\\'
const rootEsp = '../../../Intelisis/Intelisis5000/Reportes MAVI\\'

const conctRoot = R.curry( (files, root) => R.map( file => path.resolve(root, file) , files ))

const omitFls = R.without( conctRoot( ['MenuPrincipal_DLG_MAVI.esp'], './Data\\' ) )

/*** ¡¡¡ Use the root of the omit files !!! ***/
// const omitFls = R.without( conctRoot( ['MenuPrincipal_DLG_MAVI.esp'], rootEsp ) )

const espFiltFls = R.pipe(
    DrkBx.mix.fls.getFiltFls,
    omitFls
)

const gtPthToOrig = R.pipe(
    R.prop('path'),
    DrkBx.intls.newPath.toOrigFls
)

const gtMergOrgEspCmps = obj => {
    return R.set( R.lensProp('exst', obj),
        DrkBx.intls.fnCmp.mergOrgEsp( R.prop('exst', obj) )( gtPthToOrig(obj) ),
        obj
    )
}

const testInxst = obj => ( R.prop('cmpInxst', obj) != '' ) ? true : false

const testExist = obj => ( R.prop('exst', obj) != '' ) ? true : false

const addCmpsExst = obj => R.cond([
    [testExist(obj),
        DrkBx.intls.fnCmp.addCmpExst( R.prop('exst', obj) )( gtPthToOrig(obj) ) 
    ],
    [R.T, false]
])


const addCmpsInxst = obj => R.cond([
    [testInxst(obj),
        DrkBx.intls.fnCmp.addCmpInexst( R.prop('cmpInxst', obj) )( gtPthToOrig(obj) )
    ],
    [R.T, false]
])

const addCmpsToFile = R.both(addCmpsExst, addCmpsInxst)

const cutByExistAndMrg = R.pipe(
    DrkBx.intls.fnCmp.cutByExstInOrig,
    gtMergOrgEspCmps,
)

const mrgEspFl = R.pipe(
    cutByExistAndMrg,
    addCmpsToFile
)

const mrgDirEspFls = R.curry( (ext, dir) => {
    espFiltFls(ext, dir).forEach(file => {
        mrgEspFl(file)
    })
})

const conctAndMrgFls = R.pipe( conctRoot,  R.forEach(mrgEspFl) )

module.exports.mergeEsp = {
    addCmpsToFile: addCmpsToFile,
    mrgDirEspFls: mrgDirEspFls,
    mrgEspFl: mrgEspFl,
    conctAndMrgFls: conctAndMrgFls
}