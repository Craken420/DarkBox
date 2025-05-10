# 📦 encoding

> Utilidades para codificación y decodificación de datos.
> Incluye funciones para trabajar con Base64, entidades HTML, detección de codificación de archivos y más.

## 📁 Archivo fuente
`encoding/index.js`

## 🧩 Funciones Disponibles

### `base64Decode(b64)`
Decodifica una cadena codificada en Base64.
- **Parámetro:** `b64` (string)
- **Devuelve:** string decodificado

### `base64Encode(str)`
Codifica una cadena en Base64.
- **Parámetro:** `str` (string)
- **Devuelve:** string codificado en Base64

### `decodeEntity(str)`
Convierte entidades numéricas HTML en texto plano.
- **Parámetro:** `str` (string)
- **Devuelve:** string con entidades decodificadas

### `detectFileEncoding(filePath)`
Detecta la codificación de un archivo.
- **Parámetro:** `filePath` (string)
- **Devuelve:** encoding detectado (string)

### `encodeEntity(str)`
Convierte una cadena de texto a entidades HTML numéricas.
- **Parámetro:** `str` (string)
- **Devuelve:** string codificado en entidades HTML

### `readFileWithDetectedEncoding(filePath)`
Lee el contenido de un archivo con codificación detectada automáticamente.
- **Parámetro:** `filePath` (string)
- **Devuelve:** contenido decodificado (string)

### `readFileWithEncoding(filePath, targetEncoding)`
Lee el contenido de un archivo usando una codificación especificada.
- **Parámetro:** `filePath` (string), `targetEncoding` (string)
- **Devuelve:** contenido decodificado (string)

---

© MIT - Utilidades modulares para codificación.
