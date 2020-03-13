function shorter(max,s1,s2){
    var arr1 = s1.split(" "), arr2 = s2.split(" "), i = 0, l1 = arr1.length, unicas = [];
      for(;i<l1;i++){
        if((arr2.indexOf(arr1[i]) === -1) && arr1[i].length <= max) unicas.push(arr1[i]);
      }
      return unicas;
    }
    
    
    var texto = 
    "Aquí va el el primer texto a analizar e incluso con palabras lolo repetidas repetidas lala";
    var texto2 = 
    "Aquí va el segundo texto a analizar analizar e incluso con algunas palabras repetidas";
    console.log(shorter(6,texto,texto2));