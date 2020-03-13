module.exports.adapt = {
    toObject: txt => {
        txt = txt.replace(/=/g, ':').replace(/\[.*?(?=\/)|\]/g, '')
        txt = txt.replace(/(?<=\/\w+)\./g, ':').replace(/\//, '')
        txt = txt.replace(/[^\w:,\.]/gm, "").replace(/,/g, ', ')
        return txt
    },
    toRegExp: txt => {
        txt = txt.replace(/\\/g,   '\\\\')
        txt = txt.replace(/\[/g,   '\\[').replace(/\]/g, '\\]')
        txt = txt.replace(/\(/g,   '\\(').replace(/\)/g, '\\)')
        txt = txt.replace(/\{/g,   '\\{').replace(/\}/g, '\\}')
        txt = txt.replace(/\(\?/g, '\\(\\?')
        txt = txt.replace(/\+/g,   '\\+')
        txt = txt.replace(/\n/g,   '\\n')
        txt = txt.replace(/\s/g,   '\\s')
        txt = txt.replace(/\*/g,   '\\*')
        txt = txt.replace(/\$/g,   '\\$')
        txt = txt.replace(/\./g,   '\\.')
        return txt
    }
}

