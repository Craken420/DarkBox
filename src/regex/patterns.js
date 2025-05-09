/**
 * @file patterns.js
 * @fileoverview Regular expression utilities and patterns.
 * Provides reusable regex snippets and helper functions for matching,
 * validating, and ing patterns from strings.
 * Useful for parsing, input validation, and text processing tasks.
 * 
 * @module regex.patterns
 */


const file = {
    /**
     * Extracts the file extension from a path.
     * Example: 'file.txt' => '.txt'
     */
    fileExtension: /\.\w+$/,
    
    /**
     * Extracts the root of a path.
     * Example: 'c:/folder/file.txt' => 'c:/folder/'
     */
    pathRoot: /.*(\\|\/)/,

    /**
     * Extracts filename without extension from path.
     * Example: 'file.txt' => 'file'
     */
    pathWithoutExtension: /.*?(?=\.\w+$)/,
}

const iniFile = {
    /**
     * Matches opening brackets in INI block headers.
     */
    bracketOfSectionHeader: /^\[(?=.*?\]$)/gm,

    /**
     * Matches comment lines in Intelisis config files.
     */
    comments: /^;.*?/gm,

    /**
     * Captures the filename from an INI header path.
     * Example: '[Version.frm/AccionePerfilDBMail]' => 'Version.frm'
     */
    fileNameFromSectionHeader: /(?<=^\[).*?(?=\/.*?\])/g,
    
    /**
     * Matches any complete field line with a key and value.
     * Example: 'Nombre=PerfilDBMail'
     */
    fullKeyValue: /^.*?=.*?(?=(\r|\n|$))/gm,
        
    /**
     * Matches an INI block with both header and key-value fields.
     */
    iniFileWithKeyInHeader: /^\[(?=.*?\]$(\r\n|\n)^.*?=.*?$)/gm,

    /**
     * Extracts just the field name from a key-value line.
     * Example: 'Boton=84' => 'Boton'
     */
    keyName: /^.*?(?=\=)/gm,

    /**
     * Matches everything but the header in an INI block.
     * Example:
     *  Entry:
     *      [Version.frm/AccionePerfilDBMail]
     *      Nombre=PerfilDBMail
     *      Boton=84
     *  Get:
     *      Nombre=PerfilDBMail
     *      Boton=84
     */
    keysWithoutHeader: /(?<=^\[.*?\])((\r\n|\r|)(?!^\[.+?\]).*?$)+/gm,

    /**
     * Matches just the header portion of an INI block.
     * Example:
     *  Entry:
     *      [Version.frm/AccionePerfilDBMail]
     *      Nombre=PerfilDBMail
     *      Boton=84
     *  Get: [Version.frm/AccionePerfilDBMail]
     */
    sectionHeader: /^\[.*?\]$/gm,

    /**
     * Matches the entire configuration block including its header.
     * Example: [Header] Key=Value => '[Header]\nKey=Value'
     */
    sectionWithComments: /(^;.*[^]|)^\[.*?\]((\n|\r)(?!(^;.*[^]|)^\[.+?\]).*?$)+/gm,

    /**
     * Matches configuration blocks, excluding comments.
     * Example:
        ;[Version.frm/AccionePerfilDBMail]
        ;Nombre=PerfilDBMail
        ;Boton=84,
        [Version.frm/AccionePerfilDBMail]
        ;lol=lol
        Nombre=PerfilDBMail
        Boton=84
    */
    sectionWithoutComments: /^\[.*?\]((\n|\r)(?!(\n|)^\[.+?\]).*?$)+/gm,
}

const js = {
        /**
         * Matches names of arguments inside function definitions.
         * Example: function(foo, bar) => ['foo', 'bar']
         */
        argNamesFromFn: /([^\s,]+)/g,

        /**
         * Removes single-line and multi-line comments from JavaScript functions.
         */
        comments: /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg,

        /**
         * Matches constant names declared with 'const'.
         * Example: 'const myVar = ...' => 'myVar'
         */
        constantNames: /(?<=\bconst\b(\s+))\w+/g,
}

const rdp = {
    /**
     * Matches abbreviation keywords (dlg, frm, rep, tbl, vis) between underscores.
     * Example: 'Activo_Cat_FRM_Main' => 'FRM'
     */
    abbrBetweenUnderscores: /(?<=_)(dlg|frm|rep|tbl|vis)(?=_)/i,
    
    /**
     * Matches expression blocks that include specific WizardSituaciones reference.
     */
    expressionAndWizardBlock: /(?<=(?:Expresion=.*?Sino([\s\n]*?|)<br>))(?=.*?Forma\.Accion\(<T>WizardSituaciones<T>\))/gim,

    /**
     * Matches expression blocks that use WizardSituaciones.
     */
    expressionWithWizardFromKeyValue: /(?:Expresion=.*?Sino([\s\n]*?|)<br>).*?Forma\.Accion\(<T>WizardSituaciones<T>\).*?$/gim,

    /**
     * Matches keywords such as 'Expresion=...Sino...Wizard...' in INI structures.
     */
    expressionWithWizardInSituation: /(?<=^\[Acciones\.Situacion\]((\n|\r)(?!(\n|)^\[.+?\]).*?)+)(?:Expresion=.*?Sino([\s\n]*?|)<br>).*?Forma\.Accion\(<T>WizardSituaciones<T>\).*?$/gmi,

    /**
     * Matches abbreviation suffix after keyword like _FRM_ in a string.
     * Example: 'ActivoF_Cat_FRM_LOLITA' => '_LOLITA'
     */
    postAbbreviationSuffix: /(?<=.*?_(dlg|frm|rep|tbl|vis)(?=_)).*/gi,

    /**
     * Matches the prefix of a string up to the last abbreviation keyword.
     * Example: 'ActivoF_Cat_FRM_LOLITA' => 'ActivoF_Cat_FRM'
     */
    prefixBeforeAbbreviation: /.*?(?<=_)(dlg|frm|rep|tbl|vis)/gi,
}
const sql = {
    /**
     * Matches ANSI SQL settings such as SET ANSI_NULLS, etc.
     */
    ANSISettings: /SET(?:[\s\n])*(QUOTED_IDENTIFIER|ANSI_NULLS|ANSI_WARNINGS)(?:[\s\n])*(OFF|on)|GO/gi,
    
    /**
     * Matches WITH (NOLOCK/ROWLOCK) SQL hints.
     */
    detectNoLockHints: /(?:[\s\n])*with\((?:[\s\n])*(row|no)lock(?:[\s\n])*\)(?:[\s\n])*/gi,

    /**
     * Matches null comparison in CASE WHEN blocks.
     */
    detectNullComparisonInCaseWhen: /case[\s\n]*?When[^]*?(=|<>|>|<|>=|<=|!=|!<|!>)null[^]*?then/gi,

    /**
     * Matches line SQL comments starting with '--'.
     */
    lineComments: /(\-\-+).*/gm,

    /**
     * Matches multiline SQL comments.
     * Example: //*//*/*//*//*//*//*//*/*//**//*//*//*/*//*/
    */
    mltilineComments: /\/\*(?:[^/*]|\/(?!\*)|\*(?!\/))*\*\//g,

    /**
     * Detects null comparison using symbols in CASE expressions.
     */
    nullComparisonInCase: /(?<=\bcase\b([\s\n]*?.*?)when([\s\n]*?.*?)[\s\n]*?)(=|<>|>|<|>=|<=|!=|!<|!>)([\s\n]*?.*?)*?null(?=([\s\n]*?.*?)*?then([\s\n]*?.*?)*?else([\s\n]*?.*?)*?end)/gi,
}

const string = {
    /**
     * Matches any sequence of non-alphanumeric characters (used to split words).
     * Example: 'Hello, world!' => ['Hello', 'world']
     */
    wordSplit: /[^a-zA-Z0-9]+/
}

export {
    file,
    iniFile,
    js,
    rdp,
    sql,
    string
}