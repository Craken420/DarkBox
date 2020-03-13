const fs = require('fs')
const R = require('ramda')

const getTxt = file => fs.readFileSync(file, 'latin1')

const orderByAlphabet = R.pipe(
    getTxt,
    R.split(/(\r\n|\r|\n)/g),
    R.filter(Boolean),
    R.filter(x => x!= '\n'),
    R.uniq
)

const runFile = file => {
    console.log(orderByAlphabet(file).sort())
    // fs.writeFileSync(file, orderByAlphabet(file).sort().join('\n'), 'latin1')
}

runFile('C:\\Users\\lapena\\Documents\\Luis Angel\\diccionario ingles.txt')