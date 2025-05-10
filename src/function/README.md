# 🔁 function-utils

Utilidades para funciones de orden superior en JavaScript.  
Permite trabajar con composición, currificación, funciones combinadas, validación y análisis de funciones.  
Ideal para programación funcional modular.

## 📦 Instalación

```bash
npm install function-utils
```

## 🔧 Uso básico

```js
import {
  debounce,
  eitherFn,
  fork,
  getFunctionName,
  getParameterNames,
  isFunction,
  pipeEach,
  tuple
} from 'function-utils';

const log = debounce(console.log, 300);
log('Mensaje retrasado');

const double = x => x * 2;
const square = x => x * x;
const join = (a, b) => `${a}:${b}`;
console.log(fork(join, double, square)(3)); // "6:9"
```

## 📚 API

### `debounce(fn: Function, wait: number): Function`

Crea una función que se ejecuta tras una pausa de `wait` ms.

---

### `eitherFn(fn1, fn2, val): any`

Ejecuta dos funciones y devuelve el primer resultado "truthy".

---

### `fork(fnJoin, fn1, fn2): Function`

Aplica dos funciones al mismo valor y las combina con otra.

---

### `getFunctionName(func: Function): string`

Devuelve el nombre de la función (o cadena vacía si es anónima).

---

### `getParameterNames(func: Function): string[]`

Devuelve los nombres de los parámetros de una función.

---

### `isFunction(expr: any): boolean`

Verifica si una expresión es una función.

---

### `pipeEach(...funcs: Function[]): Function`

Ejecuta una serie de funciones con el mismo input (efectos secundarios).

---

### `tuple(...typeInfo: Function[]): Function`

Constructor de tipo `Tuple` con validación de tipos y valores inmutables.

```js
const isString = val => typeof val === 'string';
const isNumber = val => typeof val === 'number';

const Person = tuple(isString, isNumber);
const john = new Person('John', 30);
console.log(john.values()); // ['John', 30]
```

## 🧪 Ejemplo completo

```js
const log = debounce(console.log, 200);
log('Hello');

const paramNames = getParameterNames(function(a, b, c) {});
console.log(paramNames); // ['a', 'b', 'c']
```

## 📄 Licencia

MIT
