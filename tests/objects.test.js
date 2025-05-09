import {
    deepFreeze,
    hasntArray,
    hasObj,
    hasntObj,
    inObjPairs,
    isObj,
    isntArray,
    isntObj,
    objToSqlInserLine,
    objToTxt,
    toQuote
 } from './objects';  // Asegúrate de importar la función correctamente

    
describe('deepFreeze', () => {
  it('debe congelar un objeto simple', () => {
    const obj = { a: 1, b: 2 };
    deepFreeze(obj);
    expect(Object.isFrozen(obj)).toBe(true);
    expect(Object.isFrozen(obj.a)).toBe(true);
    expect(Object.isFrozen(obj.b)).toBe(true);
  });

  it('debe congelar un objeto con objetos anidados', () => {
    const obj = { a: 1, b: { c: 2 } };
    deepFreeze(obj);
    expect(Object.isFrozen(obj)).toBe(true);
    expect(Object.isFrozen(obj.b)).toBe(true);
    expect(Object.isFrozen(obj.b.c)).toBe(true);
  });
});

describe('hasntArray', () => {
    it('should return true for an object without arrays', () => {
        const obj = { name: 'John', age: 30 };
        expect(hasntArray(obj)).toBe(true);
    });

    it('should return false for an object containing an array', () => {
        const obj = { name: 'John', hobbies: ['reading', 'sports'] };
        expect(hasntArray(obj)).toBe(false);
    });

    it('should return true for an empty object', () => {
        const obj = {};
        expect(hasntArray(obj)).toBe(true);
    });
});

describe('hasObj', () => {
  it('debe devolver true si el objeto tiene un objeto anidado', () => {
    const obj = { a: 1, b: { c: 2 } };
    expect(hasObj(obj)).toBe(true);
  });

  it('debe devolver false si el objeto no tiene objetos anidados', () => {
    const obj = { a: 1, b: 2 };
    expect(hasObj(obj)).toBe(false);
  });
});

describe('hasntObj', () => {
  it('debe devolver true si el objeto no tiene objetos anidados', () => {
    const obj = { a: 1, b: 2 };
    expect(hasntObj(obj)).toBe(true);
  });

  it('debe devolver false si el objeto tiene un objeto anidado', () => {
    const obj = { a: 1, b: { c: 2 } };
    expect(hasntObj(obj)).toBe(false);
  });
});

describe('inObjPairs', () => {
  it('debe convertir un array de pares en un objeto', () => {
    const array = ['a', 1, 'b', 2];
    const result = inObjPairs(array);
    expect(result).toEqual({ a: 1, b: 2 });
  });

  it('debe devolver el objeto sin cambios si ya es un objeto', () => {
    const obj = { a: 1, b: 2 };
    const result = inObjPairs(obj);
    expect(result).toEqual(obj);
  });
});

describe('isObj', () => {
    it('should return true for a plain object', () => {
        const obj = { name: 'John', age: 30 };
        expect(isObj(obj)).toBe(true);
    });

    it('should return false for an array', () => {
        const arr = [1, 2, 3];
        expect(isObj(arr)).toBe(false);
    });

    it('should return false for a null value', () => {
        expect(isObj(null)).toBe(false);
    });

    it('should return false for a function', () => {
        const func = () => {};
        expect(isObj(func)).toBe(false);
    });

    it('should return false for a primitive value', () => {
        expect(isObj('string')).toBe(false);
    });
});

describe('isntArray', () => {
    it('should return true for an object', () => {
        const obj = { name: 'John' };
        expect(isntArray(obj)).toBe(true);
    });

    it('should return true for a string', () => {
        const str = 'hello';
        expect(isntArray(str)).toBe(true);
    });

    it('should return false for an array', () => {
        const arr = [1, 2, 3];
        expect(isntArray(arr)).toBe(false);
    });

    it('should return true for a number', () => {
        const num = 42;
        expect(isntArray(num)).toBe(true);
    });
});

describe('isntObj', () => {
    it('should return false for a plain object', () => {
        const obj = { name: 'John' };
        expect(isntObj(obj)).toBe(false);
    });

    it('should return true for an array', () => {
        const arr = [1, 2, 3];
        expect(isntObj(arr)).toBe(true);
    });

    it('should return true for a string', () => {
        const str = 'hello';
        expect(isntObj(str)).toBe(true);
    });

    it('should return true for a number', () => {
        const num = 42;
        expect(isntObj(num)).toBe(true);
    });

    it('should return true for null', () => {
        const nullValue = null;
        expect(isntObj(nullValue)).toBe(true);
    });
});

describe('objToSqlInserLine', () => {
  it('debe convertir un objeto plano en una línea SQL', () => {
    const obj = { id: 1, name: 'John' };
    const result = objToSqlInserLine(obj);
    expect(result).toBe("INSERT INTO TblName (id, name) VALUES (1, 'John');");
  });

  it('debe devolver null para estructuras no soportadas', () => {
    const obj = [1, 2, 3];
    const result = objToSqlInserLine(obj);
    expect(result).toBeNull();
  });
});

describe('objToTxt', () => {
  it('debe convertir un objeto en una cadena de texto clave:valor', () => {
    const obj = { a: 1, b: 'test' };
    const result = objToTxt(obj);
    expect(result).toBe('a:1, b:"test"');
  });

  it('debe manejar objetos anidados correctamente', () => {
    const obj = { a: 1, b: { c: 2 } };
    const result = objToTxt(obj);
    expect(result).toBe('a:1, b:"{"c":2}"');
  });
});

describe('toQuote', () => {
  it('debe agregar comillas a una cadena', () => {
    const result = toQuote('Hello');
    expect(result).toBe('"Hello"');
  });

  it('debe devolver "Object:null" para valores nulos', () => {
    const result = toQuote(null);
    expect(result).toBe('Object:null');
  });

  it('debe procesar objetos correctamente', () => {
    const obj = { key: 'value' };
    const result = toQuote(obj);
    expect(result).toEqual({ key: '"value"' });
  });
});
