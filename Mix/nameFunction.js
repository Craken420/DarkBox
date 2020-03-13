var ola = function (x) {
    console.log( arguments.callee.name )
    console.log(arguments.callee.arguments)
}
ola();