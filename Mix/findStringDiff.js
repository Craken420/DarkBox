function findStringDiff(str1, str2) {
    var compareString = function(str1, str2) {
        var a1 = str1.split("");
        var a2 = str2.split("");
        var idx2 = 0;
        a1.forEach(function(val) {
            if (a2[idx2] === val) {
              a2.splice(idx2,1);
            } else {
                idx2 += 1;
            }
        });
        if (idx2 > 0) {
            a2.splice(idx2,a2.length);
        }
        return a2.join("");
    }

    if (str1.length < str2.length) {
        return compareString(str1, str2);
    } else {
        return compareString(str2, str1);
    }
}

console.log(findStringDiff("test xyz","test ab xyz"));