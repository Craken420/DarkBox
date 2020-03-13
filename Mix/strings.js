

module.exports.fnStrs = (function () {
    
    const _countCharact = txt => {
        if (txt) {
            if (/./g.test(txt)) {
                return txt.match(/./g).length
            } else {
                return 0
            }
        } else {
            return 0
        }
    }

    function countCharact (array) { return _countCharact(array) }

    return {
        countCharact
    }

})()