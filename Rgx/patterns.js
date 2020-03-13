
module.exports.patt = {
    /* Path */

    //=> Entry: 'c:/Path/Name File.txt' Get: 'Name File.txt'
    pathRoot: /.*(\\|\/)/,
    pathExt: /\.\w+$/,
    pathUntilExt: /.*?(?=\.\w+$)/,

    nameOfConst: /(?<=\bconst\b(\s+))\w+/g,

    /* SQL */

    ansis: /SET(?:[\s\n])*(QUOTED_IDENTIFIER|ANSI_NULLS|ANSI_WARNINGS)(?:[\s\n])*(OFF|on)|GO/gi,

    sqlMultiLineComments: /\/\*(?:[^/*]|\/(?!\*)|\*(?!\/))*\*\//g,

    sqlLineComments: /(\-\-+).*/gm,

    sqlSymbolCmprNullInCase: /(?<=\bcase\b([\s\n]*?.*?)when([\s\n]*?.*?)[\s\n]*?)(=|<>|>|<|>=|<=|!=|!<|!>)([\s\n]*?.*?)*?null(?=([\s\n]*?.*?)*?then([\s\n]*?.*?)*?else([\s\n]*?.*?)*?end)/gi,
    
    sqlCaseCmprNull: /case[\s\n]*?When[^]*?(=|<>|>|<|>=|<=|!=|!<|!>)null[^]*?then/gi,
    
    withNo: /(?:[\s\n])*with\((?:[\s\n])*(row|no)lock(?:[\s\n])*\)(?:[\s\n])*/gi,

    /* Intelisis */
    intlsComments: /^;.*?/gm,

    //=> Entry: 'ActivoF_Cat_FRM_MAVI' Get: '_MAVI'
    aftrAbbrtObj: /(?<=.*?_(dlg|frm|rep|tbl|vis)(?=_)).*/gi,

    //=> _FRM_
    abbrtObjBtwnLowScripts: /(?<=_)(dlg|frm|rep|tbl|vis)(?=_)/i,

    //=> Entry: 'ActivoF_Cat_FRM_MAVI' Get: 'ActivoF_Cat_FRM'
    bfrAbbrtObj: /.*?(?<=_)(dlg|frm|rep|tbl|vis)/gi,


    cmpEnterInHead: /^\[(?=.*?\]$(\r\n|\n)^.*?=.*?$)/gm,

    fldIniLineOfField: /^(?=.*?=.*?$)/gm,

    compBraketOfHead: /^\[(?=.*?\]$)/gm,

    expresionElseWizardInSituacion: /(?<=^\[Acciones\.Situacion\]((\n|\r)(?!(\n|)^\[.+?\]).*?)+)(?:Expresion=.*?Sino([\s\n]*?|)<br>).*?Forma\.Accion\(<T>WizardSituaciones<T>\).*?$/gmi,

    btweenExpresionAndWizard: /(?<=(?:Expresion=.*?Sino([\s\n]*?|)<br>))(?=.*?Forma\.Accion\(<T>WizardSituaciones<T>\))/gim,

    fldExpresionWithWizard: /(?:Expresion=.*?Sino([\s\n]*?|)<br>).*?Forma\.Accion\(<T>WizardSituaciones<T>\).*?$/gim,

    /*
    //=> Entry:
        [Version.frm/AccionePerfilDBMail]
        Nombre=PerfilDBMail
        Boton=84
    //=> Get:'[Version.frm/AccionePerfilDBMail]'
    */
    compHead: /^\[.*?\]$/gm,

    /*
    //=> Get: [
                '[Version.frm/AccionePerfilDBMail]
                    Nombre=PerfilDBMail
                    Boton=84',
                '[Version.frm/AccionePerfilDBMail]
                    Nombre=PerfilDBMail
                    Boton=84'
            ]
        '
    */
    compAll: /^\[.*?\]((\n|\r)(?!(\n|)^\[.+?\]).*?$)+/gm,
    cmpAllWithComments: /(^;.*[^]|)^\[.*?\]((\n|\r)(?!(^;.*[^]|)^\[.+?\]).*?$)+/gm,

    /*
    //=> Entry:
        [Version.frm/AccionePerfilDBMail]
        Nombre=PerfilDBMail
        Boton=84
    //=> Get:
        Nombre=PerfilDBMail
        Boton=84
    */
    cmpOmitHead: /(?<=^\[.*?\])((\r\n|\r|)(?!^\[.+?\]).*?$)+/gm,

    /*
    //=> Entry:
        [Version.frm/AccionePerfilDBMail]
        Nombre=PerfilDBMail
        Boton=84
    //=> Get:'Version.frm'
    */
    cmpNameFile: /(?<=^\[).*?(?=\/.*?\])/g,

    fldFull: /^.*?=.*?(?=(\r|\n|$))/gm,

    fldName: /^.*?(?=\=)/gm

    
}
