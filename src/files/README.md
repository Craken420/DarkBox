# 📁 files-utils

Utilidades para trabajar con archivos en Node.js.  
Permite leer, escribir, validar, filtrar y procesar archivos en disco de forma eficiente.

## 📦 Instalación

```bash
npm install files-utils
```

## 🔧 Uso básico

```js
import {
  checkAndCreateFile,
  deleteIfEmpty,
  existsAndIsFile,
  filterFilesByExt,
  getFilteredFilesInDir,
  getPathsInDir,
  isFile,
  readFile,
  toEspFileCheckAndCreate,
  toEspFilenameInDir,
  writeFile
} from 'files-utils';

const result = checkAndCreateFile('./example.txt');
console.log(result); // { file: './example.txt', status: 'Created' | 'Exist' }
```

## 📚 API

### `checkAndCreateFile(file: string): { file: string, status: 'Created' | 'Exist' }`

Crea un archivo vacío si no existe.

---

### `deleteIfEmpty(file: string): boolean`

Elimina el archivo si está vacío.

---

### `existsAndIsFile(file: string): boolean`

Verifica si el archivo existe y es un archivo (no directorio).

---

### `filterFilesByExt(extensions: string[], files: string[]): string[]`

Filtra una lista de rutas por extensiones.

---

### `getFilteredFilesInDir(extensions: string[], dir: string): string[]`

Devuelve archivos en un directorio que coinciden con extensiones dadas.

---

### `getPathsInDir(dir: string): string[]`

Devuelve las rutas absolutas de todos los elementos dentro de un directorio.

---

### `isFile(file: string): boolean`

Verifica si una ruta es un archivo.

---

### `readFile(filePath: string): Promise<string>`

Lee el contenido de un archivo de texto de forma asíncrona.

---

### `toEspFileCheckAndCreate(dir: string, file: string): { file: string, status: 'Created' | 'Exist' }`

Verifica o crea la versión `.txt` con sufijo `_esp` del archivo original en un directorio dado.

---

### `toEspFilenameInDir(dir: string, file: string): string`

Genera el nombre del archivo `_esp.txt` basado en otro archivo.

---

### `writeFile(filePath: string, data: string): Promise<void>`

Escribe texto a un archivo de forma asíncrona (crea o sobreescribe).

---

## 🧪 Ejemplo completo

```js
const inputDir = './data';
const extensions = ['.txt'];

const files = getFilteredFilesInDir(extensions, inputDir);
files.forEach(file => {
  const espPath = toEspFilenameInDir(inputDir, file);
  writeFile(espPath, 'Texto de ejemplo').then(() => {
    console.log('Archivo generado:', espPath);
  });
});
```

## 📄 Licencia

MIT
