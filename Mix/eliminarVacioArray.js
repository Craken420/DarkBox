var myArr = [ 'foo', 0, '', undefined, 'blue', null, 5, false, NaN];
myArrClean = myArr.filter(Boolean);

console.log(myArrClean)