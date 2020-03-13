
module.exports.fnNum = (function () {
  const _isOdd = num => {
    if(num % 2 == 0) {
      return "pair";
    }
    else {
      return "impair";
    }
  }

  function isOdd (array) { return _isOdd(array) }

  return {
    isOdd
  }

})();
