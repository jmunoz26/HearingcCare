# 🔒 Checklist de Seguridad - HearingCare API

## ✅ Archivos Protegidos en .gitignore

### 🔐 Claves y Secretos
- [x] `/config/master.key` - Clave maestra de Rails
- [x] `/config/credentials/*.key` - Claves de credenciales
- [x] `.env` y `.env.*` - Variables de entorno
- [x] `/.kamal/secrets` - Secretos de deployment
- [x] `*.pem`, `*.key`, `*.crt` - Certificados y claves privadas

### 🗄️ Base de Datos
- [x] `*.sqlite3` - Archivos de base de datos SQLite
- [x] `*.sql`, `*.dump` - Dumps de base de datos
- [x] `/config/database.yml.local` - Configuración local de DB

### 📝 Logs y Temporales
- [x] `/log/*` - Logs de la aplicación
- [x] `/tmp/*` - Archivos temporales
- [x] `/storage/*` - Archivos subidos por usuarios

### 🔧 Herramientas
- [x] `.vscode/`, `.idea/` - Configuraciones de IDEs
- [x] `/coverage/` - Reportes de cobertura de tests

---

## ⚠️ ARCHIVOS QUE NUNCA DEBES SUBIR

### 🚫 CRÍTICO - Nunca subir estos archivos:

1. **`config/master.key`**
   - Contiene la clave para desencriptar credentials
   - Si se filtra, toda la seguridad se compromete
   - ✅ Ya está en .gitignore

2. **`.env` o archivos `.env.*`**
   - Contienen contraseñas de base de datos
   - API keys y tokens
   - ✅ Ya está en .gitignore

3. **`.kamal/secrets`**
   - Contiene secretos de deployment
   - ✅ Ya está en .gitignore

4. **Dumps de base de datos (`.sql`, `.dump`)**
   - Pueden contener datos sensibles de usuarios
   - ✅ Ya está en .gitignore

---

## ✅ ARCHIVOS SEGUROS PARA SUBIR

### ✓ Estos archivos SÍ deben estar en el repositorio:

1. **`config/credentials.yml.enc`**
   - Está encriptado, es seguro
   - Necesita `master.key` para desencriptarse

2. **`config/database.yml`**
   - ✅ SOLO si no contiene contraseñas hardcodeadas
   - ✅ Usa variables de entorno: `<%= ENV["PASSWORD"] %>`

3. **`.env.example`**
   - Plantilla sin valores reales
   - Ayuda a otros desarrolladores

4. **`Gemfile` y `Gemfile.lock`**
   - Necesarios para instalar dependencias

5. **Código fuente** (`app/`, `config/`, `lib/`)
   - Modelos, controladores, rutas, etc.

---

## 🔍 VERIFICACIÓN ANTES DE COMMIT

### Ejecuta estos comandos antes de hacer commit:

```bash
# 1. Verificar que master.key NO esté rastreado
git ls-files | grep master.key
# Resultado esperado: (vacío)

# 2. Verificar que .env NO esté rastreado
git ls-files | grep "\.env$"
# Resultado esperado: (vacío)

# 3. Verificar archivos que se van a subir
git status

# 4. Ver cambios específicos
git diff config/database.yml
# Asegúrate de que NO haya contraseñas hardcodeadas
```

---

## 🛡️ CONFIGURACIÓN ACTUAL

### ✅ Estado de seguridad:

- [x] `.gitignore` actualizado para Rails
- [x] `config/master.key` protegido
- [x] `.env.example` creado como plantilla
- [x] Variables de entorno configuradas en `database.yml`
- [x] CORS configurado
- [x] `bcrypt` instalado para contraseñas

### ⚠️ Recomendaciones adicionales:

1. **Rotar el master.key si ya fue expuesto:**
   ```bash
   rm config/master.key config/credentials.yml.enc
   rails credentials:edit
   ```

2. **Usar variables de entorno en producción:**
   - No hardcodear contraseñas en ningún archivo
   - Usar servicios como Heroku Config Vars, AWS Secrets Manager, etc.

3. **Habilitar autenticación de 2 factores en GitHub:**
   - Protege tu repositorio de accesos no autorizados

4. **Revisar periódicamente:**
   ```bash
   # Buscar posibles secretos en el código
   git grep -i "password\s*=\s*['\"]"
   git grep -i "api_key\s*=\s*['\"]"
   ```

---

## 📋 CHECKLIST FINAL ANTES DE PUSH

- [ ] Ejecuté `git status` y revisé todos los archivos
- [ ] No hay archivos `.env` en la lista
- [ ] No hay `config/master.key` en la lista
- [ ] No hay dumps de base de datos (`.sql`, `.dump`)
- [ ] Revisé `config/database.yml` y no tiene contraseñas hardcodeadas
- [ ] Creé un commit con mensaje descriptivo
- [ ] Estoy listo para hacer `git push`

---

## 🚨 SI ACCIDENTALMENTE SUBISTE UN SECRETO

### Pasos inmediatos:

1. **Rotar TODAS las credenciales expuestas**
   - Cambiar contraseñas de base de datos
   - Regenerar API keys
   - Crear nuevo master.key

2. **Eliminar del historial de Git:**
   ```bash
   # Usar BFG Repo-Cleaner o git filter-branch
   # ADVERTENCIA: Esto reescribe el historial
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch config/master.key" \
     --prune-empty --tag-name-filter cat -- --all
   
   git push origin --force --all
   ```

3. **Notificar al equipo**
   - Todos deben hacer `git pull --force`

4. **Monitorear por actividad sospechosa**

---

## 📚 Recursos

- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)

