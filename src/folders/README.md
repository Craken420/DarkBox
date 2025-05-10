# 📂 folders-utils

Utilidades para trabajar con estructuras de carpetas en Node.js.  
Permite crear, validar, recorrer y filtrar archivos dentro de directorios de forma eficiente y funcional.

## 📦 Instalación

```bash
npm install folders-utils
```

## 🔧 Uso básico

```js
import {
  createFolder,
  existsAndIsDirectory,
  getFiles,
  getFilesExcluding,
  getFilteredFiles,
  getFilteredFilesExcluding,
  isDirectory,
  listFiles,
  resolveFilePath,
  resolveFilePaths
} from 'folders-utils';

await createFolder('./my-folder');
const files = getFiles('./my-folder');
console.log(files);
```

## 📚 API

### `createFolder(dirPath: string): Promise<void>`

Crea un directorio si no existe (modo recursivo).

---

### `existsAndIsDirectory(directoryPath: string): boolean`

Verifica si una ruta existe y es un directorio.

---

### `getFiles(directory: string): string[]`

Devuelve solo los archivos (no carpetas) de un directorio.

---

### `getFilesExcluding(directory: string, namesToOmit: string[]): string[]`

Devuelve archivos excluyendo los nombres especificados.

---

### `getFilteredFiles(extensions: string[], directory: string): string[]`

Filtra archivos por extensiones dentro de un directorio.

---

### `getFilteredFilesExcluding(directory: string, extensions: string[], namesToOmit: string[]): string[]`

Filtra archivos por extensión y excluye archivos por nombre.

---

### `isDirectory(directoryPath: string): boolean`

Verifica si una ruta es un directorio.

---

### `listFiles(dirPath: string): Promise<string[]>`

Lista solo los archivos (no carpetas) dentro de un directorio (modo async).

---

### `resolveFilePath(directory: string, fileName: string): string`

Resuelve la ruta completa de un archivo dentro de un directorio.

---

### `resolveFilePaths(directory: string, files: string[]): string[]`

Resuelve múltiples rutas de archivos dentro de un directorio.

---

## 🧪 Ejemplo completo

```js
const dir = './data';
await createFolder(dir);

const extensions = ['.txt'];
const omitNames = ['omit.txt'];

const files = getFilteredFilesExcluding(dir, extensions, omitNames);
console.log('Archivos filtrados:', files);
```

## 📄 Licencia

MIT
