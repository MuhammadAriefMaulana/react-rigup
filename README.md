### Prepare Database:

* Buat database dengan nama **rigdb_rev2**
* Import database:
    * Pertama import **rigdb_rev2(include-create-schema).sql**
    * Kedua import **table-view-rev(not-include-create-schema__just-import-to-rigdb_rev2).sql**

### Backend Server:

* Jika terdapat error di backend server, lakukan sedikit perubahan didalam project backend, buka file config/database.js Ubah script 
**const mysql = require('mysql')** menjadi const **mysql = require('mysql2')**

### Frontend:

Ubah API_URL sesuai dengan alamat backend server kamu di dalam file:
**/src/support/API_URL.js**


### See other repo :
https://github.com/MuhammadAriefMaulana/react-rigup-infra