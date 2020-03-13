const {arregloCampos} = require('../Archivos/arregloCamposIntelisis')
const { getObjsSQL } = require('../Abductor/getObjsSQL')
const { arregloSinDuplicado } = require('./eliminarDuplicado')
const { decode } = require('./decode')
const { extraerContenidoRecodificado } = require('../Codificacion/contenidoRecodificado')
const { continua } = require('./continua')

const fs = require('fs')
const cntnt = require('../Abductor/getContentsAllFields')
const intls = require('../Abductor/getObjsIntls')
const opObj = require('../OperadorObjetos/deleteEmptyObj')
const rgx = require('../RegEx/jsonRgx')

function verifiReturn (objIntls, objSQL, text) {
    
    if (JSON.stringify(objIntls) != '{}' && JSON.stringify(objSQL) != '{}') {
 
        if (objIntls && objSQL) {
            return {
                objIntls: objIntls,
                objSQL: objSQL
            }
        } else if (objSQL) {
            return {
                objSQL:objSQL
            }
        } else if (objIntls) {
            return {
                objIntls: objIntls
            }
        } else {
            return false
        }

    }  else if (JSON.stringify(objSQL) != '{}') {
        if (objSQL) {
            return {
                objSQL:objSQL
            }
        }  else {
            return false
        }
    } else if (JSON.stringify(objIntls) != '{}') {
        if (objIntls) {
            return {
                objIntls: objIntls
            }
        }
    } else {
        return false
    }
}

function getObjs (text) {
    let objIntls = intls.getObjsIntls(text)
    //console.log(objIntls)
    let objSQL = getObjsSQL(text)
    if (verifiReturn(objIntls, objSQL, text)) {
        //console.log(verifiReturn(objIntls, objSQL, text))
        return verifiReturn(objIntls, objSQL, text)
    }
}


function limpiarObjeto(cutObj, cmp, field) {

    delete cutObj[cmp]['TipoAccion']

    if (typeof(cutObj[cmp][field]) == 'string') {
        // console.log(cutObj[cmp][field])
        delete cutObj[cmp][field]
    }

    if (cutObj[cmp]['ClaveAccion']){
        if (typeof(cutObj[cmp]['ClaveAccion']) == 'string') {
            if (!/Formas|Reportes|Dialogos/gi.test(cutObj[cmp]['ClaveAccion'])) {
                delete cutObj[cmp]['ClaveAccion']
            }
        }
    }
}

function generarReporte(objGeneral, clave) {
    
    if (objGeneral['fn'] || objGeneral['sp'] || objGeneral['tb'] || objGeneral['dlg'] || objGeneral['frm'] || objGeneral['rep'] || objGeneral['tbl'] || objGeneral['variables']) {
       
        fs.appendFileSync('Reportes\\' + clave,
            `-------------------------------------------------------`
            + `\n--> TITULO: ${clave}`
            + `\n-------------------------------------------------------`
            + `\n\nOBJETOS CONTENIDOS`
        )
        
        if (objGeneral['fn'] || objGeneral['sp'] || objGeneral['tb']){
            
            fs.appendFileSync('Reportes\\' + clave,
                `\n\n-------------------------------------------------------`
                + `\n--> SQL`
            )
        }

        if (objGeneral['fn']) {
            fs.appendFileSync('Reportes\\' + clave,
                `\n-------------------------------------------------------`
                + `\nFunciones:`
                + `\n-------------------------------------------------------\n`
                + `${ objGeneral['fn'].replace(/,/g, '\n')}`
            )
        }

        if (objGeneral['sp']) {
            fs.appendFileSync('Reportes\\' + clave,
                `\n\n-------------------------------------------------------`
                + `\nProcedimientos Almacenados:`
                + `\n-------------------------------------------------------\n`
                + `${ objGeneral['sp'].replace(/,/g, '\n')}`
            )
        }

        if (objGeneral['tb']) {
            fs.appendFileSync('Reportes\\' + clave,
                `\n\n-------------------------------------------------------`
                + `\nTablas:`
                + `\n-------------------------------------------------------\n`
                + `${ objGeneral['tb'].replace(/,/g, '\n')}`
            )
        }

        if (objGeneral['dlg'] || objGeneral['frm'] || objGeneral['rep'] || objGeneral['tbl'] || objGeneral['variables']){
            fs.appendFileSync('Reportes\\' + clave,
                `\n\n-------------------------------------------------------`
                + `\n--> INTELISIS`
            )
        }

        if (objGeneral['dlg']) {
        fs.appendFileSync('Reportes\\' + clave,
            `\n\n-------------------------------------------------------`
            + `\nDialogos:`
            + `\n-------------------------------------------------------\n`
            + `${ objGeneral['dlg'].replace(/,/g, '\n')}`
        )}

        if (objGeneral['frm']) {
            fs.appendFileSync('Reportes\\' + clave,
                  `\n\n-------------------------------------------------------`
                + `\nFormas:`
                + `\n-------------------------------------------------------\n`
                + `${ objGeneral['frm'].replace(/,/g, '\n')}`
            )
        }

        if (objGeneral['plugin']) {
            fs.appendFileSync('Reportes\\' + clave,
                  `\n\n-------------------------------------------------------`
                + `\nPlig ins:`
                + `\n-------------------------------------------------------\n`
                + `${ objGeneral['plugin'].replace(/,/g, '\n')}`
            )
        }

        if (objGeneral['rep']) {
            fs.appendFileSync('Reportes\\' + clave,
                  `\n\n-------------------------------------------------------`
                + `\nReportes:`
                + `\n-------------------------------------------------------\n`
                + `${ objGeneral['rep'].replace(/,/g, '\n')}`
            )
        }

        if (objGeneral['tbl']) {
            fs.appendFileSync('Reportes\\' + clave,
                  `\n\n-------------------------------------------------------`
                + `\nTablas:`
                + `\n-------------------------------------------------------\n`
                + `${ objGeneral['tbl'].replace(/,/g, '\n')}`
            )
        }

        if (objGeneral['variables']) {
            fs.appendFileSync('Reportes\\' + clave,
                  `\n\n-------------------------------------------------------`
                + `\nVariables:`
                + `\n-------------------------------------------------------\n`
                + `${ objGeneral['variables'].replace(/,/g, '\n')}`
            )
        }
    }
}

function cargarObjeto (cutObj) {

    let objGeneral = []

    let arrSP = []
    let arrFn = []
    let arrTb = []

    let arrDlg = []
    let arrFrm = []
    let arrPlugin = []
    let arrRep= []
    let arrTbl = []
    let arrVariables = []

    opObj.deleteObjEmpty(cutObj)

    for (key2 in cutObj) {

        for (key3 in cutObj[key2]) {

            if (cutObj[key2][key3]['objSQL']) {
                if (cutObj[key2][key3]['objSQL']['sp']) {
                    arrSP.push(cutObj[key2][key3]['objSQL']['sp'])
                }
                if (cutObj[key2][key3]['objSQL']['fn']) {
                    arrFn.push(cutObj[key2][key3]['objSQL']['fn'])
                }
                if (cutObj[key2][key3]['objSQL']['tb']) {
                    arrTb.push(cutObj[key2][key3]['objSQL']['tb'])
                }
            }

            if (cutObj[key2][key3]['objIntls']) {
                if (cutObj[key2][key3]['objIntls']['frm']) {
                    arrFrm.push(cutObj[key2][key3]['objIntls']['frm'])
                }
                if (cutObj[key2][key3]['objIntls']['dlg']) {
                    arrDlg.push(cutObj[key2][key3]['objIntls']['dlg'])
                }
                if (cutObj[key2][key3]['objIntls']['plugin']) {
                    arrPlugin.push(cutObj[key2][key3]['objIntls']['plugin'])
                }
                if (cutObj[key2][key3]['objIntls']['tbl']) {
                    arrTbl.push(cutObj[key2][key3]['objIntls']['tbl'])
                }
                if (cutObj[key2][key3]['objIntls']['rep']) {
                    arrRep.push(cutObj[key2][key3]['objIntls']['rep'])
                }
                if (cutObj[key2][key3]['objIntls']['variables']) {
                    arrVariables.push(cutObj[key2][key3]['objIntls']['variables'])
                }
            }
        }
    }

    if (arrFn.length != 0) {
        objGeneral['fn'] = arregloSinDuplicado(arrFn.join(',').split(',')).join(',')
    }
    if (arrSP.length != 0) {
        objGeneral['sp'] = arregloSinDuplicado(arrSP.join(',').split(',')).join(',')
    }
    if (arrTb.length != 0) {
        objGeneral['tb'] = arregloSinDuplicado(arrTb.join(',').split(',')).join(',')
    }
    if (arrDlg.length != 0) {
        objGeneral['dlg'] = arregloSinDuplicado(arrDlg.join(',').split(',')).join(',')
    }
    if (arrFrm.length != 0) {
        objGeneral['frm'] = arregloSinDuplicado(arrFrm.join(',').split(',')).join(',')
    }
    if (arrPlugin.length != 0) {
        objGeneral['plugin'] = arregloSinDuplicado(arrPlugin.join(',').split(',')).join(',')
    }
    if (arrRep.length != 0) {
        objGeneral['rep'] = arregloSinDuplicado(arrRep.join(',').split(',')).join(',')
    }
    if (arrTbl.length != 0) {
        objGeneral['tbl'] = arregloSinDuplicado(arrTbl.join(',').split(',')).join(',')
    }
    if (arrVariables.length != 0) {
        objGeneral['variables'] = arregloSinDuplicado(arrVariables.join(',').split(',')).join(',')
    }
    // console.log('------------------------------------------')
    // console.log(cutObj)
    // console.log('------------------------------------------')

    return {
        ['Relacion De Objs']: objGeneral,
        ['Detalle']: cutObj
    }
}


function desglozar (obj, name) {

    name = name.replace(/.*\\/g, '')
    name = name.replace(/\.(?=\w{3}$)/, '_')
    name = name.replace(/$/, '.txt')
    name = name.replace(/^/, 'RO-')

    let cutObj = {}

    cutObj = JSON.parse( JSON.stringify( obj ) )

    cntnt.getFields(arregloCampos, cutObj)
    // console.log('import\n',cntnt.getFields(arregloCampos, cutObj))
    for (keyCmp in cutObj) {

        let cmp = keyCmp
  
        let objs = {}

        for (keyField in cutObj[cmp]) {

            let field = keyField

            if (cutObj[cmp][field]){
                objs = getObjs(cutObj[cmp][field])
            
            if (objs) {
                console.log(objs)
                cutObj[cmp][field] = objs
                
            }
            // console.log('Positin', cutObj[cmp][field] )
            let objsInField = intls.getObjInClaveAccion(cutObj, cmp, field)
            // console.log('Positin: ', cutObj[cmp][field] )
            
            if (objsInField) {
                // console.log('objsInField: ', objsInField)
                cutObj[cmp]['ClaveAccion'] =  objsInField
            }

            limpiarObjeto(cutObj, cmp, field)
            // console.log('Positin: ', cutObj[cmp][field])
            // console.log('-----------------------------------------------')
            // console.log('Obj')
            // console.log(objs)
            // console.log('-----------------------------------------------')
            }
        }
    }

    let objFinal = cargarObjeto(cutObj)
    // console.log(objFinal)
    generarReporte(objFinal['Relacion De Objs'], name)
    return objFinal
}

function recorrerDetalle (obj) {
/*** Recorrer el detalle ***/
    for (path in obj) {
        // console.log(obj[path])
        for (cmp in obj[path]['Detalle']) {
            // console.log(obj[path]['Detalle'][cmp])
            // console.log('[' + cmp + ']')
            for (field in obj[path]['Detalle'][cmp]) {
                // console.log(obj[path]['Detalle'][cmp][field])
                if (obj[path]['Detalle'][cmp][field]['objIntls']) {
                    // console.log(field + '= ',
                    obj[path]['Detalle'][cmp][field]['objIntls']
                    // console.log('-----------------------------------------------')
                }
                if (obj[path]['Detalle'][cmp][field]['objSQL']) {
                    // console.log('-----------------------------------------------')
                    // console.log(field + '= ',
                    obj[path]['Detalle'][cmp][field]['objSQL']
                    // console.log('-----------------------------------------------')
                }
            }
        }
    }
}

function generarObj(pathFile) {

    let obj = {}

    let objFile = decode(
            rgx.Borrar.clsComentariosSQL(
                rgx.Borrar.clsComentariosIntls(
                    extraerContenidoRecodificado(pathFile)
                )
            ).replace(/&/g, '')
        )

    let sendObj = JSON.parse( JSON.stringify( objFile ) )

    obj[rgx.Borrar.clsRuta(pathFile)] = desglozar(continua(sendObj), pathFile)

// console.log(obj)

//Recorrer el arreglo de formas y por cada una buscar si existe y volver a ejecutar

    return obj
}

module.exports.generarObj = generarObj