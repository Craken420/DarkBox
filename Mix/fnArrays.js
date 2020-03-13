module.exports.fnArray = (function () {
    
    const _uniq = array => {
        let set = new Set( array.map( JSON.stringify))
        return Array.from(set).map( JSON.parse )
    }

    function uniq (array) { return _uniq(array) }

    return {
        uniq
    }

})()
