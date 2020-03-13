const { DrkBx } = require('../DarkBox')
// const fs = require('fs')
// const XLSX = require('xlsx')
// const R = require('Ramda')



//#region Files

    //#region getExcelInObj
        // const cDirExcelInObj = './Resources/'
        // const cFileExcelInObj = 'CRED-ANX-001 CONFIG INTL DINERALIA.xlsx'
        // console.log( DrkBx.file.getExcelInObj(cDirExcelInObj + cFileExcelInObj, 3) )
        // console.log( DrkBx.file.getExcelInObj(cDirExcelInObj + cFileExcelInObj, [3, 4]) )
    //#endregion getExcelInObj

//#endregion Files


//#region Objects

    //#region  objToTxt

        //#region Resources
            // const objToTxt13 = [
            //     {
            //       'File': 'dbo.Agent.Table.sql',
            //       'Lines': [ 164, 166, 173 ],
            //       'Status': 'Geted'
            //     },
            //     {
            //       'File': 'dbo.Agente.Table.sql',
            //       'Lines': [ 259, 328 ],
            //       'Status': 'Geted'
            //     },
            //     {
            //       'File': 'dbo.AjusteAnual.StoredProcedure.sql',
            //       'Lines': [ 42, 57 ],
            //       'Status': 'Geted'
            //     },
            //     {
            //       'File': 'dbo.Alm.Table.sql',
            //       'Lines': [ 95, 102 ],
            //       'Status': 'Geted'
            //     },
            //     {
            //       'File': 'dbo.aroRiesgo.Table.sql',
            //       'Lines': [ 57, 64 ],
            //       'Status': 'Geted'
            //     }
            // ]

            // const objToTxt12 = {
            //     "glossary": {
            //         null: null,
            //         "Null1": null,
            //         "title": "example glossary",
            //         "GlossDiv": {
            //             "title": "S",
            //             "GlossList": {
            //                 "GlossEntry": {
            //                     "ID": "SGML",
            //                     "SortAs": "SGML",
            //                     "GlossTerm": "Standard Generalized Markup Language",
            //                     "Acronym": "SGML",
            //                     "popup": {
            //                         "menuitem": [
            //                             {"value": "New", "onclick": "CreateNewDoc()"},
            //                             {"value": "Open", "onclick": "OpenDoc()"},
            //                             {
            //                                 "value": "Close", 
            //                                 "onclick": {
            //                                     "menuitem": [
            //                                         {"value": "New", "onclick": "CreateNewDoc()"},
            //                                         {"value": "Open", "onclick": "OpenDoc()"},
            //                                         {
            //                                             "value": "Close",
            //                                             "popup": {
            //                                                 "menuitem": [
            //                                                     {"value": "New", "onclick": "CreateNewDoc()"},
            //                                                     {"value": "Open", "onclick": "OpenDoc()"},
            //                                                     {"value": ["File", "Folder"], "onclick": "CloseDoc()"}
            //                                                 ]
            //                                             }
            //                                         }
            //                                     ]
            //                                 }
            //                             }
            //                         ]
            //                     },
            //                     "Abbrev": "ISO 8879:1986",
            //                     "GlossDef": {
            //                         "para": "A meta-markup language, used to create markup languages such as DocBook.",
            //                         "GlossSeeAlso": ["GML", {
            //                             "menuitem": [
            //                                 {"value": "New", "onclick": "CreateNewDoc()"},
            //                                 {"value": "Open", "onclick": "OpenDoc()"},
            //                                 {"value": ["File", "Folder"], "onclick": "CloseDoc()"}
            //                             ]
            //                         }]
            //                     },
            //                     "GlossSee": ["File", "Folder"]
            //                 }
            //             }
            //         }
            //     }
            // }

            // const objToTxt11 = {
            //     "glossary": {
            //         "Null1": null,
            //         'Num1': 1,
            //         "NullWord1": "null",
            //         "object":{"value": "New", "onclick": "CreateNewDoc()"}
            //     }
            // }

            // const objToTxt10 = {
            //     "glossary": {
            //         "title": "example glossary",
            //         "GlossDiv": {
            //             "title": "S",
            //             "GlossList": {
            //                 "GlossEntry": {
            //                     "ID": "SGML",
            //                     "SortAs": "SGML",
            //                     "GlossTerm": "Standard Generalized Markup Language",
            //                     "Acronym": "SGML",
            //                     "popup": {
            //                         "menuitem": [
            //                             {"value": "New", "onclick": "CreateNewDoc()"},
            //                             {"value": "Open", "onclick": "OpenDoc()"},
            //                             {
            //                                 "value": "Close", 
            //                                 "onclick": {
            //                                     "menuitem": [
            //                                         {"value": "New", "onclick": "CreateNewDoc()"},
            //                                         {"value": "Open", "onclick": "OpenDoc()"},
            //                                         {
            //                                             "value": "Close"
            //                                         }
            //                                     ]
            //                                 }
            //                             }
            //                         ]
            //                     },
            //                     "Abbrev": "ISO 8879:1986",
            //                     "GlossDef": {
            //                         "para": "A meta-markup language, used to create markup languages such as DocBook.",
            //                         "GlossSeeAlso": ["GML", "lao"]
            //                     },
            //                     "GlossSee": ["File", "Folder"]
            //                 }
            //             }
            //         }
            //     }
            // }

            // const objToTxt9 = {
            //     "menu": {
            //         "id": "file",
            //         "value": "File",
            //         "popup": {
            //             "menuitem": [
            //                 {"value": "New", "onclick": "CreateNewDoc()"},
            //                 {"value": "Open", "onclick": "OpenDoc()"},
            //                 {"value": "Close", "onclick": "CloseDoc()"}
            //             ]
            //         }
            //     }
            // }

            // const objToTxt8 = {
            //     "menu": {
            //         "id": "file",
            //         "value": "File",
            //         "popup": {
            //             "menuitem": [
            //                 "value",
            //                 "Open",
            //             "onclick"
            //             ]
            //         }
            //     }
            // }

            // const objToTxt7 = [
            //     {
            //         "menu": {
            //             "id": "file",
            //             "value": "File"
            //         }
            //     }
            // ]

            // const objToTxt6 = {
            //     "id": "file",
            //     "value": "File",
            //     "menu": {
            //         "id": {
            //             "idieee": "fileeee",
            //             "valueeeee": "Fileeeee"
            //         },
            //         "value": "File"
            //     }
            // }

            // const objToTxt5 = {
            //     "id": "file",
            //     "value": "File",
            //     "menu": {
            //         "id": "file",
            //         "value": "File"
            //     }
            // }

            // const objToTxt4 = {
            //     "id": "1726",
            //     "value": ["File", "Folder"]
            // }

            // const objToTxt3 = {
            //     "id": "1726",
            //     "value": {
            //         "id": "1726",
            //         "value": {
            //             "id": "1726",
            //             "value": "File"
            //         }
            //     }
            // }

            // const arrayToTxt3 = ['id', '1726', 'value', ["File", ["File", "Folder"] ] ]

            // const objToTxt2 = {
            //     "id": "1726",
            //     "value": {
            //         "id": "1726",
            //         "value": "File"
            //     }
            // }

            // const arrayToTxt2 = ['id', '1726', 'value', ["File", "Folder"] ]

            // const objToTxt1 = {
            //     "id": "1726",
            //     "value": "File"
            // }

            // const arrayToTxt1 = ['id', '1726', 'value', 'File']

            // const stringToTxt1 = 'Hola'

            // const stringToTxt0 = ''
        
            // const intToTxt0 = 0

            // const boolToTxt0 = true

            // const objToTxt0 = {}

            // const arrayToTxt0 = []
        //#endregion Resources

        //#region Usage
            // console.log( 'stringToTxt0: \n', DrkBx.objs.objToTxt(stringToTxt0) )
            // console.log( 'stringToTxt0: \n', DrkBx.objs.objToTxt(stringToTxt1) )
            // console.log( 'intToTxt0:    \n', DrkBx.objs.objToTxt(intToTxt0)    )
            // console.log( 'boolToTxt0:   \n', DrkBx.objs.objToTxt(boolToTxt0)   )
            // console.log( 'objToTxt0:    \n', DrkBx.objs.objToTxt(objToTxt0)    )
            // console.log( 'arrayToTxt0:  \n', DrkBx.objs.objToTxt(arrayToTxt0)  )
            // console.log( 'objToTxt1:    \n', DrkBx.objs.objToTxt(objToTxt1)    )
            // console.log( 'arrayToTxt1:  \n', DrkBx.objs.objToTxt(arrayToTxt1)  )
            // console.log( 'objToTxt2:    \n', DrkBx.objs.objToTxt(objToTxt2)    )
            // console.log( 'arrayToTxt2:  \n', DrkBx.objs.objToTxt(arrayToTxt2)  )
            // console.log( 'objToTxt3:    \n', DrkBx.objs.objToTxt(objToTxt3)    )
            // console.log( 'arrayToTxt3:  \n', DrkBx.objs.objToTxt(arrayToTxt3)  )
            // console.log( 'objToTxt4:    \n', DrkBx.objs.objToTxt(objToTxt4)    )
            // console.log('objToTxt4:    \n', DrkBx.objs.objToTxt(objToTxt4) )
            // console.log( 'objToTxt5:    \n', DrkBx.objs.objToTxt(objToTxt5)    )
            // console.log( 'objToTxt6:    \n', DrkBx.objs.objToTxt(objToTxt6)    )
            // console.log( 'objToTxt7:    \n', DrkBx.objs.objToTxt(objToTxt7)    )
            // console.log( 'objToTxt8:    \n', DrkBx.objs.objToTxt(objToTxt8)    )
            // console.log( 'objToTxt9:    \n', DrkBx.objs.objToTxt(objToTxt9)    )
            // console.log( 'objToTxt10:   \n', DrkBx.objs.objToTxt(objToTxt10)   )
            // console.log( 'objToTxt11:   \n', DrkBx.objs.objToTxt(objToTxt11)   )
            // console.log( 'objToTxt12:   \n', DrkBx.objs.objToTxt(objToTxt12)   )
            // console.log( 'objToTxt13:   \n', DrkBx.objs.objToTxt(objToTxt13)   )
        //#endregion Usage
    
    //#endregion objToTxt


    //#region arrayInObjPairs 

        //#region Resources
      
            // const arrayInObjPairs10 = [ ["vocales MIn",["a","e","i","o","u"], ["vocales mayu",["A","E","I","O","U"], 'lol', ["tipos", ["categoria", ["asento", ["aguda", "esdrugula"] ] ] ]] ]] 
            // const arrayInObjPairs9 = [ ["vocales MIn", ["a","e","i","o","u"] ] ] 
           
            // const arrayInObjPairs8 = ['numeros', '1726', 'letras', ["abecedario", ["vocales MIn",["a","e","i","o","u"] ] ] ]
            
            // const arrayInObjPairs7 = [ ['id', '1726'], ['value', 'File'] ]

            // const arrayInObjPairs6 = ['id', '1726', 'value', ["File", ["nan", "nun"], "lol"] ]

            // const arrayInObjPairs5 = ['id', '1726', 'value', ["File", ["nan", "nun"]] ]

            // const arrayInObjPairs4 = ['id', '1726', 'value', ["File", "Folder"] ]

            // const arrayInObjPairs3 = ['id', '1726', 'value', 'File', 'Fone', 'cool', 'nan']

            // const arrayInObjPairs2 = ['id', '1726', 'value', 'File', 'Fone']

            

            // const arrayInObjPairs1 = ['id', '1726', 'value', 'File']

            // const stringInObjPairs1 = 'Hola'

            // const stringObjPairs0 = ''
        
            // const intInObjPairs0 = 0

            // const boolInObjPairs0 = true

            // const objInObjPairs1 = {
            //     "id": "1726",
            //     "value": "File"
            // }

            // const objInObjPairs0 = {}

            // const arrayInObjPairs0 = []
        //#endregion Resources

        //#region Usage
            // console.log( 'objInObjPairs0:    \n', DrkBx.objs.inObjPairs(objInObjPairs0)     )
            // console.log( 'arrayInObjPairs0:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs0)   )
            // console.log( 'stringInObjPairs1: \n', DrkBx.objs.inObjPairs(stringInObjPairs1)  )
            // console.log( 'intInObjPairs0:    \n', DrkBx.objs.inObjPairs(intInObjPairs0)     )
            // console.log( 'boolInObjPairs0:   \n', DrkBx.objs.inObjPairs(boolInObjPairs0)    )
            // console.log( 'objInObjPairs1:    \n', DrkBx.objs.inObjPairs(objInObjPairs1)     )
            // console.log( 'arrayInObjPairs1:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs1)   )
            // console.log( 'arrayInObjPairs2:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs2)   )
            // console.log( 'arrayInObjPairs3:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs3)   )
            // console.log( 'arrayInObjPairs4:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs4) )
            // console.log( 'arrayInObjPairs5:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs5) )
            // console.log( 'arrayInObjPairs6:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs6)   )
            // console.log( 'arrayInObjPairs7:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs7)   )
            // console.log( 'arrayInObjPairs8:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs8)   )
            // console.log(DrkBx.objs.objToTxt(DrkBx.objs.inObjPairs(arrayInObjPairs8)))
            // fs.writeFileSync('reportInObjPairs8.txt', DrkBx.objs.objToTxt(DrkBx.objs.inObjPairs(arrayInObjPairs8)))
            // console.log( 'arrayInObjPairs9:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs9)   )
            // console.log( 'arrayInObjPairs10:  \n', DrkBx.objs.inObjPairs(arrayInObjPairs10)   )
            // fs.writeFileSync('reportInObjPairs10.txt',   DrkBx.objs.objToTxt(DrkBx.objs.inObjPairs(arrayInObjPairs10)))
        //#endregion Usage
    
    //#endregion arrayInObjPairs


    //#region objToSqlLine

        //#region Resources
            // const objToSqlInserLine11 = {
            //     "glossary": {
            //         "title": "example glossary",
            //         "GlossDiv": {
            //             "title": "S",
            //             "GlossList": {
            //                 "GlossEntry": {
            //                     "ID": "SGML",
            //                     "SortAs": "SGML",
            //                     "GlossTerm": "Standard Generalized Markup Language",
            //                     "Acronym": "SGML",
            //                     "popup": {
            //                         "menuitem": [
            //                             {"value": "New", "onclick": "CreateNewDoc()"},
            //                             {"value": "Open", "onclick": "OpenDoc()"},
            //                             {
            //                                 "value": "Close", 
            //                                 "onclick": {
            //                                     "menuitem": [
            //                                         {"value": "New", "onclick": "CreateNewDoc()"},
            //                                         {"value": "Open", "onclick": "OpenDoc()"},
            //                                         {
            //                                             "value": "Close",
            //                                             "popup": {
            //                                                 "menuitem": [
            //                                                     {"value": "New", "onclick": "CreateNewDoc()"},
            //                                                     {"value": "Open", "onclick": "OpenDoc()"},
            //                                                     {"value": ["File", "Folder"], "onclick": "CloseDoc()"}
            //                                                 ]
            //                                             }
            //                                         }
            //                                     ]
            //                                 }
            //                             }
            //                         ]
            //                     },
            //                     "Abbrev": "ISO 8879:1986",
            //                     "GlossDef": {
            //                         "para": "A meta-markup language, used to create markup languages such as DocBook.",
            //                         "GlossSeeAlso": ["GML", {
            //                             "menuitem": [
            //                                 {"value": "New", "onclick": "CreateNewDoc()"},
            //                                 {"value": "Open", "onclick": "OpenDoc()"},
            //                                 {"value": ["File", "Folder"], "onclick": "CloseDoc()"}
            //                             ]
            //                         }]
            //                     },
            //                     "GlossSee": ["File", "Folder"]
            //                 }
            //             }
            //         }
            //     }
            // }

            // const objToSqlInserLine10 = {
            //     "glossary": {
            //         "title": "example glossary",
            //         "GlossDiv": {
            //             "title": "S",
            //             "GlossList": {
            //                 "GlossEntry": {
            //                     "ID": "SGML",
            //                     "SortAs": "SGML",
            //                     "GlossTerm": "Standard Generalized Markup Language",
            //                     "Acronym": "SGML",
            //                     "popup": {
            //                         "menuitem": [
            //                             {"value": "New", "onclick": "CreateNewDoc()"},
            //                             {"value": "Open", "onclick": "OpenDoc()"},
            //                             {
            //                                 "value": "Close", 
            //                                 "onclick": {
            //                                     "menuitem": [
            //                                         {"value": "New", "onclick": "CreateNewDoc()"},
            //                                         {"value": "Open", "onclick": "OpenDoc()"},
            //                                         {
            //                                             "value": "Close"
            //                                         }
            //                                     ]
            //                                 }
            //                             }
            //                         ]
            //                     },
            //                     "Abbrev": "ISO 8879:1986",
            //                     "GlossDef": {
            //                         "para": "A meta-markup language, used to create markup languages such as DocBook.",
            //                         "GlossSeeAlso": ["GML", "lao"]
            //                     },
            //                     "GlossSee": ["File", "Folder"]
            //                 }
            //             }
            //         }
            //     }
            // }

            // const objToSqlInserLine9 = {
            //     "menu": {
            //         "id": "file",
            //         "value": "File",
            //         "popup": {
            //             "menuitem": [
            //                 {"value": "New", "onclick": "CreateNewDoc()"},
            //                 {"value": "Open", "onclick": "OpenDoc()"},
            //                 {"value": "Close", "onclick": "CloseDoc()"}
            //             ]
            //         }
            //     }
            // }

            // const objToSqlInserLine8 = {
            //     "menu": {
            //         "id": "file",
            //         "value": "File",
            //         "popup": {
            //             "menuitem": [
            //                 "value",
            //                 "Open",
            //             "onclick"
            //             ]
            //         }
            //     }
            // }

            // const objToSqlInserLine7 = [
            //     {
            //         "menu": {
            //             "id": "file",
            //             "value": "File"
            //         }
            //     }
            // ]

            // const objToSqlInserLine6 = {
            //     "id": "file",
            //     "value": "File",
            //     "menu": {
            //         "id": {
            //             "idieee": "fileeee",
            //             "valueeeee": "Fileeeee"
            //         },
            //         "value": "File"
            //     }
            // }

            // const objToSqlInserLine5 = {
            //     "id": "file",
            //     "value": "File",
            //     "menu": {
            //         "id": "file",
            //         "value": "File"
            //     }
            // }

            // const objToSqlInserLine4 = {
            //     "id": "1726",
            //     "value": ["File", "Folder"]
            // }

            // const objToSqlInserLine3 = {
            //     "id": "1726",
            //     "value": {
            //         "id": "1726",
            //         "value": {
            //             "id": "1726",
            //             "value": "File"
            //         }
            //     }
            // }

            // const arrayToSqlInserLine3 = ['id', '1726', 'value', ["File", ["File", "Folder"] ] ]

            // const objToSqlInserLine2 = {
            //     "id": "1726",
            //     "value": {
            //         "id": "1726",
            //         "value": "File"
            //     }
            // }

            // const arrayToSqlInserLine2 = ['id', '1726', 'value', ["File", "Folder"] ]

            // const objToSqlInserLine1 = {
            //     "id": "1726",
            //     "value": "File"
            // }

            // const arrayToSqlInserLine1 = ['id', '1726', 'value', 'File']

            // const stringToSqlInserLine1 = 'Hola'

            // const stringToSqlInserLine0 = ''

            // const intToSqlInserLine0 = 0

            // const boolToSqlInserLine0 = true

            // const objToSqlInserLine0 = {}

            // const arrayToSqlInserLine0 = []
        //#endregion Resources
        
        //#region Usage
            // console.log( 'stringToSqlInserLine0: \n', DrkBx.objs.objToSqlInserLine(stringToSqlInserLine0) )
            // console.log( 'stringToSqlInserLine1: \n', DrkBx.objs.objToSqlInserLine(stringToSqlInserLine1) )
            // console.log( 'intToSqlInserLine0:    \n', DrkBx.objs.objToSqlInserLine(intToSqlInserLine0)    )
            // console.log( 'boolToSqlInserLine0:   \n', DrkBx.objs.objToSqlInserLine(boolToSqlInserLine0)   )
            // console.log( 'objToSqlInserLine0:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine0)    )
            // console.log( 'arrayToSqlInserLine0:  \n', DrkBx.objs.objToSqlInserLine(arrayToSqlInserLine0)  )
            // console.log( 'objToSqlInserLine1:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine1)    )
            // console.log( 'arrayToSqlInserLine1:  \n', DrkBx.objs.objToSqlInserLine(arrayToSqlInserLine1)  )
            // console.log( 'objToSqlInserLine2:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine2)    )
            // console.log( 'arrayToSqlInserLine2:  \n', DrkBx.objs.objToSqlInserLine(arrayToSqlInserLine2)  )
            // console.log( 'objToSqlInserLine3:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine3)    )
            // console.log( 'arrayToSqlInserLine3:  \n', DrkBx.objs.objToSqlInserLine(arrayToSqlInserLine3)  )
            // console.log( 'objToSqlInserLine4:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine4)    )
            // console.log( 'objToSqlInserLine5:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine5)    )
            // console.log( 'objToSqlInserLine6:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine6)    )
            // console.log( 'objToSqlInserLine7:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine7)    )
            // console.log( 'objToSqlInserLine8:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine8)    )
            // console.log( 'objToSqlInserLine9:    \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine9)    )
            // console.log( 'objToSqlInserLine10:   \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine10)   )
            // console.log( 'objToSqlInserLine11:   \n', DrkBx.objs.objToSqlInserLine(objToSqlInserLine11)   )
        //#endregion Usage
    
    //#endregion objToSqlLine

//#endregion Objects


//#region Rgx

    //#region Make

        //#region sqlCmprNullIn

            // let strCmprNullTest1 = `IF (@IDagente != NULL)
            //             BEGIN 
            //             INSERT INTO DM0021ComisionChoferSGarantia (IdAgente,Nombre,Tipo,FechaAlta,NoQuincenas,FechaPago,Categoria,Estatus) VALUES (@IDagente,@NombreAgente,@TipoAgenta,@FechaA,@NoQuincena,@FechaG,@CategoriaAgente,@EstatusAgente)
            //             END
            //         END`
            // let strCmprNullTest2 = `IF @FechaInicio IS NOT NULL AND @FechaAnterior != NULL
            //         UPDATE MovTiempo WITH(ROWLOCK)`


            // let strCmprNullTest3 = `IF @FechaInicio <> NULL SELECT @FechaInicio = @Ahora
            //         INSERT INTO MovTiempo (Modulo,  Sucursal,  ID,  Usuario,  FechaInicio,  FechaComenzo, Estatus,       Situacion)
            //         VALUES (@Modulo, @Sucursal, @ID, @Usuario, @FechaInicio, @Ahora,       @EstatusNuevo, @SituacionNueva)
            //         END` 

            // console.log( DrkBx.make.sqlCmprNullIn('if') )
            // console.log( R.test( DrkBx.make.sqlCmprNullIn('if'), strCmprNullTest1  ) )
            // console.log( 'Match if: \n', R.match(DrkBx.make.sqlCmprNullIn('if'), strCmprNullTest1) )

            // console.log( R.test( DrkBx.make.sqlCmprNullIn('and'), strCmprNullTest2  ) )
            // console.log( 'Match and: \n', R.match(DrkBx.make.sqlCmprNullIn('and'), strCmprNullTest2) )

            // console.log( R.test( DrkBx.make.sqlCmprNullIn('if'), strCmprNullTest3  ) )
            // console.log( 'Match if: \n', R.match(DrkBx.make.sqlCmprNullIn('if'), strCmprNullTest3) )
        //#endregion sqlCmprNullIn

        //#region sqlSymbolCmprNullIn

            // let strSymbolCmprTest1 = `IF (@IDagente != NULL)
            //                                 BEGIN 
            //                                 INSERT INTO DM0021ComisionChoferSGarantia (IdAgente,Nombre,Tipo,FechaAlta,NoQuincenas,FechaPago,Categoria,Estatus) VALUES (@IDagente,@NombreAgente,@TipoAgenta,@FechaA,@NoQuincena,@FechaG,@CategoriaAgente,@EstatusAgente)
            //                                 END
            //                             END`
            // let strSymbolCmprTest2 = `IF @FechaInicio IS NOT NULL AND @FechaAnterior != NULL
            //     UPDATE MovTiempo WITH(ROWLOCK)`


            // let strSymbolCmprTest3 = `IF @FechaInicio <> NULL SELECT @FechaInicio = @Ahora
            //     INSERT INTO MovTiempo (Modulo,  Sucursal,  ID,  Usuario,  FechaInicio,  FechaComenzo, Estatus,       Situacion)
            //     VALUES (@Modulo, @Sucursal, @ID, @Usuario, @FechaInicio, @Ahora,       @EstatusNuevo, @SituacionNueva)
            // END`    

            // console.log( DrkBx.make.sqlSymbolCmprNullIn('if') )
            // console.log( R.test( DrkBx.make.sqlSymbolCmprNullIn('if'), strSymbolCmprTest1  ) )
            // console.log( 'Test 1 Match IF: \n', R.match(DrkBx.make.sqlSymbolCmprNullIn('if'), strSymbolCmprTest1) )

            // console.log( R.test( DrkBx.make.sqlSymbolCmprNullIn('and'), strSymbolCmprTest2  ) )
            // console.log( 'Test 2 Match AND: \n', R.match(DrkBx.make.sqlSymbolCmprNullIn('and'), strSymbolCmprTest2) )

            // console.log( R.test( DrkBx.make.sqlSymbolCmprNullIn('if'), strSymbolCmprTest3  ) )
            // console.log( 'Test 3 Match IF: \n', R.match(DrkBx.make.sqlSymbolCmprNullIn('if'), strSymbolCmprTest3) )
        //#endregion sqlCompareWithIsNull  
        
    //#endregion Make

//#endregion Rgx


//#region SQL

        //#region SQLCompare wih null

            /* Resources */
            // const dirSQLCompare = './Resources/'
            // const filesToRunCompr = [
            //     dirSQLCompare + 'dbo.FN_MAVIRM0822CONTAUXCOSTOVENTAS.UserDefinedFunction.sql',
            //     dirSQLCompare + 'dbo.PropreListaD.Table.sql',
            //     dirSQLCompare + 'dbo.sp_AuxCostoVentasMAVI.StoredProcedure.sql',
            //     dirSQLCompare + 'dbo.sp_AuxNotVtasCredMAVI.StoredProcedure.sql',
            //     dirSQLCompare + 'dbo.sp_DeterCostoVtasMAVI.StoredProcedure.sql',
            //     dirSQLCompare + 'dbo.Agent.Table.sql',
            //     dirSQLCompare + 'dbo.Agente.Table.sql'
            // ]

            /* Run one file */
                // const resultCompr = My.Tools.comprWithNull.getInFile(
                //        './Resources/dbo.Agente.Table.sql') // Get Conds WithNull Ej: '= Null'

                // const resultCompr = My.Tools.comprWithNull.replaceInFile(
                //     './Resources/dbo.Agente.Table.sql') // Cond WithNull Ej: '= Null' x 'IsNull'


            /* Run indicates files */
                // const resultCompr = My.Tools.comprWithNull.getInTheseFiles(
                //                                       filesToRunCompr)  // Get Conds WithNull Ej: '= Null'
                // const resultCompr = My.Tools.comprWithNull.replaceInTheseFiles(
                //                                    filesToRunCompr) // Cond WithNull Ej: '= Null' x 'IsNull'


            /* Folder and extentions of the files */
                // const resultCompr =  My.Tools.comprWithNull.getInDir(
                //     ['.sql','.vis','.frm','.esp','.tbl','.rep','.dlg'],
                //     dirSQLCompare
                // ) // Get Conds WithNull Ej: '= Null'

                //  const resultCompr = My.Tools.comprWithNull.replaceInDir(
                //       ['.sql','.vis','.frm','.esp','.tbl','.rep','.dlg'],
                //       dirSQLCompare
                //  ) // Cond WithNull Ej: '= Null' x 'IsNull'


            //--------------------------------------------------------------------------------------

            /* Mostrar el resultado */
                // console.log(resultCompr)

            /* To save the result in a report */
                // if (resultCompr) fs.writeFileSync('Data\\ReportCompr.txt', 
                //    'Comparaciones con \"IS NULL\" en los archivos:\n\n' 
                //    + 
                //     DrkBx.objs.objToTxt(resultCompr)
                //     , 'Latin1')
                // else console.log('Not Result')

        //#endregion SQLCompare wih null

        //#region  ExcelToSQLInsertLine

            /* Resources */
                // const cDirSQLInsertLine = './Resources/'
                // const cFileSQLInsertLine = 'CRED-ANX-001 CONFIG INTL DINERALIA.xlsx'
            /* Run one file */
                // let result1SQLInsertLine = My.Tools.ExcelToSQLInsertLine.getLine(cDirSQLInsertLine + cFileSQLInsertLine, 9)
                // let result2SQLInsertLine = My.Tools.ExcelToSQLInsertLine.getLine(cDirSQLInsertLine + cFileSQLInsertLine, [9,10])

            /* Get report */
                // let resultRep1SQLInsertLine = My.Tools.ExcelToSQLInsertLine.getReport(cDirSQLInsertLine + cFileSQLInsertLine, 9)
                // let resultRep2SQLInsertLine = My.Tools.ExcelToSQLInsertLine.getReport(cDirSQLInsertLine + cFileSQLInsertLine, [9,10])

            /* Show´s result */
                // console.log(result1SQLInsertLine)
                // console.log(result2SQLInsertLine)
                // console.log(resultRep1SQLInsertLine)
                // console.log(resultRep2SQLInsertLine)

        //#endregion ExcelToSQLInsertLine

//#endregion SQL


//#region other

//#endregion other