import * as R from 'ramda';
import * as patt from './patterns.js';

const cmpEnterInHead = R.replace(patt.cmpBraketOfHead, '\n[')

export {
    cmpEnterInHead
}