import { debounce, diff, eitherFn, fork, getFunctionName, getParameterNames, isFunction, pipeEach, tuple } from './function'; // ajusta la ruta de importación según sea necesario
import { expect } from 'chai'; // o cualquier otro framework de aserciones que prefieras

describe('Higher-order utilities and function wrappers', () => {

  // Pruebas para debounce
  describe('debounce', () => {
    it('should throw an error when invalid arguments are passed', () => {
      expect(() => debounce('string', 200)).to.throw(TypeError);
      expect(() => debounce(() => {}, 'not-a-number')).to.throw(TypeError);
    });

    it('should debounce a function', (done) => {
      let counter = 0;
      const debouncedFn = debounce(() => { counter++; }, 100);

      debouncedFn();
      debouncedFn();

      setTimeout(() => {
        expect(counter).to.equal(1);
        done();
      }, 150);
    });
  });

  // Pruebas para diff
  describe('diff', () => {
    it('should return an empty array when objects are equal', () => {
      const obj1 = { a: 1, b: 2 };
      const obj2 = { a: 1, b: 2 };
      expect(diff(obj1, obj2)).to.deep.equal([]);
    });

    it('should return the keys from obj1 that are not in obj2', () => {
      const obj1 = { a: 1, b: 2, c: 3 };
      const obj2 = { a: 1, b: 2 };
      expect(diff(obj1, obj2)).to.deep.equal(['c']);
    });

    it('should remove keys with identical values in both objects', () => {
      const obj1 = { a: 1, b: 2 };
      const obj2 = { a: 1, b: 2, c: 3 };
      expect(diff(obj1, obj2)).to.deep.equal(['c']);
    });
  });

  // Pruebas para eitherFn
  describe('eitherFn', () => {
    it('should return the first truthy result', () => {
      const fn1 = (val) => val > 0 ? val : null;
      const fn2 = (val) => val <= 0 ? val : null;
      
      expect(eitherFn(fn1, fn2, -5)).to.equal(-5);
      expect(eitherFn(fn1, fn2, 10)).to.equal(10);
    });
  });

  // Pruebas para fork
  describe('fork', () => {
    it('should apply both functions and merge results', () => {
      const add1 = (val) => val + 1;
      const multiplyBy2 = (val) => val * 2;
      const join = (x, y) => x + y;

      const fn = fork(join, add1, multiplyBy2);
      expect(fn(5)).to.equal(11); // (5 + 1) + (5 * 2) = 11
    });
  });

  // Pruebas para getFunctionName
  describe('getFunctionName', () => {
    it('should return the name of a named function', () => {
      function testFn() {}
      expect(getFunctionName(testFn)).to.equal('testFn');
    });

    it('should return an empty string for anonymous functions', () => {
      const fn = function () {};
      expect(getFunctionName(fn)).to.equal('');
    });

    it('should throw error for non-function arguments', () => {
      expect(() => getFunctionName('not a function')).to.throw(TypeError);
    });
  });

  // Pruebas para getParameterNames
  describe('getParameterNames', () => {
    it('should return parameter names as an array', () => {
      function testFn(a, b, c) {}
      expect(getParameterNames(testFn)).to.deep.equal(['a', 'b', 'c']);
    });

    it('should return an empty array for functions with no parameters', () => {
      function testFn() {}
      expect(getParameterNames(testFn)).to.deep.equal([]);
    });
  });

  // Pruebas para isFunction
  describe('isFunction', () => {
    it('should return true for a function', () => {
      function testFn() {}
      expect(isFunction(testFn)).to.be.true;
    });

    it('should return false for non-function types', () => {
      expect(isFunction('string')).to.be.false;
      expect(isFunction({})).to.be.false;
    });
  });

  // Pruebas para pipeEach
  describe('pipeEach', () => {
    it('should execute all functions in sequence', () => {
      let result = 0;
      const increment = () => { result += 1; };
      const double = () => { result *= 2; };

      const fn = pipeEach(increment, double);
      fn();
      expect(result).to.equal(2); // 0 + 1 = 1, then 1 * 2 = 2
    });
  });

  // Pruebas para tuple
  describe('tuple', () => {
    it('should create a tuple with correct types', () => {
      const Tuple = tuple(Number, String);
      const t = new Tuple(1, 'test');
      expect(t.values()).to.deep.equal([1, 'test']);
    });

    it('should throw an error if tuple contains null or undefined', () => {
      const Tuple = tuple(Number, String);
      expect(() => new Tuple(1, null)).to.throw(ReferenceError);
    });

    it('should throw an error if tuple arity does not match', () => {
      const Tuple = tuple(Number, String);
      expect(() => new Tuple(1)).to.throw(TypeError);
    });
  });

});
