Number.prototype.pad = function(size) {
	var s = String(this);
	while (s.length < (size || 2)) {s = "0" + s;}
	return s;
}

const continua = objeto => {
	Object.keys(objeto).forEach(com => {
		let del = []
		Object.keys(objeto[com]).forEach(item => {
			if(/\d{3}$/gi.test(item)){
				del.push(item)
			}
			if(/<CONTINUA>$/gi.test(objeto[com][item]) && !/\d{3}$/gi.test(item)){
				let actual = item
				let proximo = item.match(/^(\w|\().+(?<!\d)/gm).join('') + 
					(!/\d{3}$/gi.test(item) ? '002' : (parseInt(item.match(/\d{3}$/gi).join(''))+1).pad(3))
				while(/<CONTINUA>$/gi.test(objeto[com][actual]) && /^<CONTINUA>/gi.test(objeto[com][proximo])){
					objeto[com][item] = objeto[com][item].replace(/<CONTINUA>$/gi,'')
					objeto[com][proximo] = objeto[com][proximo].replace(/^<CONTINUA>/gi,'')
					objeto[com][item] = objeto[com][item] + objeto[com][proximo]
					actual = proximo
					proximo = actual.match(/^(\w|\().+(?<!\d)/gm).join('') + 
						(!/\d{3}$/gi.test(actual) ? '002' : (parseInt(actual.match(/\d{3}$/gi).join(''))+1).pad(3))
				}
				objeto[com][item] = objeto[com][item].replace(/<CONTINUA>$/gi,'')
			}
		})
		del.forEach(d => delete objeto[com][d])
	})
	return objeto
}

module.exports.continua = continua