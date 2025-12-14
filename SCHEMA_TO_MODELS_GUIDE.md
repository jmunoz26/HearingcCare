# 📚 Guía: Generar Modelos desde Base de Datos Existente

## 🎯 Resumen

Cuando ya tienes una base de datos con tablas creadas manualmente, Rails **NO** detecta automáticamente los modelos. Necesitas crearlos manualmente o usar herramientas de ayuda.

---

## 🔧 Opciones Disponibles

### 1. **`schema_to_scaffold`** (Antigua, no recomendada)

**Instalación:**
```bash
gem install schema_to_scaffold
```

**Uso:**
```bash
schema_to_scaffold table_name
```

**Ejemplo:**
```bash
schema_to_scaffold patients
# Genera: rails generate scaffold Patient name:string phone:string dob:date
```

**❌ Problemas:**
- No está actualizada para Rails 8
- No detecta bien las relaciones (foreign keys)
- Genera código innecesario para APIs
- No mantiene el código actualizado

---

### 2. **`annotate`** (Recomendada para documentación)

**Qué hace:**
- Agrega comentarios automáticos a tus modelos con la estructura de la tabla
- Se actualiza automáticamente cuando cambias el esquema
- Muy útil para equipos grandes

**Instalación:**
```ruby
# Gemfile
group :development do
  gem 'annotate'
end
```

```bash
bundle install
rails g annotate:install
annotate --models
```

**Resultado:**
```ruby
# == Schema Information
#
# Table name: patients
#
#  id           :uuid, not null
#  name         :text, not null
#  phone        :text
#  created_at   :timestamptz, not null
#  updated_at   :timestamptz, not null
#

class Patient < ApplicationRecord
  # tu código aquí
end
```

**⚠️ Nota:** Actualmente no soporta Rails 8.1 (esperando actualización)

---

### 3. **Script Personalizado** (Lo que creamos)

Creamos dos tareas Rake personalizadas:

#### **a) Inspeccionar la base de datos:**
```bash
rails db:inspect
```

**Muestra:**
- Todas las tablas
- Columnas con tipos y restricciones
- Foreign keys (relaciones)
- Índices
- Comandos scaffold sugeridos

#### **b) Anotar modelos:**
```bash
rails db:annotate_models
```

**Agrega comentarios de esquema a todos los modelos existentes**

---

## 🚀 Proceso Recomendado

### **Paso 1: Inspeccionar la base de datos**
```bash
rails db:inspect
```

Esto te muestra toda la estructura y te sugiere comandos scaffold.

### **Paso 2: Crear modelos manualmente**

Basándote en la inspección, crea los modelos con:
- Relaciones (`belongs_to`, `has_many`)
- Validaciones
- Scopes
- Métodos helper

**Ejemplo:**
```ruby
class Patient < ApplicationRecord
  belongs_to :user, optional: true
  has_many :appointments
  has_many :orders
  
  validates :name, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  
  def age
    return nil unless dob
    ((Time.zone.now - dob.to_time) / 1.year.seconds).floor
  end
end
```

### **Paso 3: Anotar modelos**
```bash
rails db:annotate_models
```

Esto agrega la documentación del esquema automáticamente.

---

## 📋 Comparación de Herramientas

| Herramienta | Genera Modelos | Genera Relaciones | Actualización | Rails 8.1 |
|-------------|----------------|-------------------|---------------|-----------|
| `schema_to_scaffold` | ✅ | ❌ | ❌ | ❌ |
| `annotate` | ❌ | ❌ | ✅ | ❌ |
| Script personalizado | ✅ (manual) | ✅ (manual) | ✅ | ✅ |
| Manual | ✅ | ✅ | ✅ | ✅ |

---

## 💡 Mejores Prácticas

1. **Inspecciona primero:** Usa `rails db:inspect` para entender la estructura
2. **Crea modelos manualmente:** Más control y mejor código
3. **Agrega relaciones:** Identifica foreign keys y crea `belongs_to`/`has_many`
4. **Valida:** Agrega validaciones basadas en las restricciones de la DB
5. **Documenta:** Usa `rails db:annotate_models` para mantener documentación
6. **Prueba:** Verifica las relaciones en la consola de Rails

---

## 🧪 Verificar que funciona

```bash
rails console
```

```ruby
# Verificar conteos
User.count
Patient.count

# Verificar relaciones
patient = Patient.first
patient.appointments
patient.orders

# Verificar validaciones
user = User.new
user.valid?
user.errors.full_messages
```

---

## 📝 Comandos Útiles

```bash
# Ver estructura de una tabla
rails runner "puts ActiveRecord::Base.connection.columns(:users).inspect"

# Ver todas las tablas
rails runner "puts ActiveRecord::Base.connection.tables.inspect"

# Ver foreign keys
rails runner "puts ActiveRecord::Base.connection.foreign_keys(:orders).inspect"

# Inspeccionar base de datos completa
rails db:inspect

# Anotar modelos
rails db:annotate_models
```

---

## ✅ Lo que hicimos en este proyecto

1. ✅ Detectamos las tablas existentes
2. ✅ Creamos 6 modelos con relaciones completas
3. ✅ Agregamos validaciones basadas en el esquema
4. ✅ Creamos scopes útiles
5. ✅ Agregamos métodos helper
6. ✅ Documentamos con comentarios de esquema
7. ✅ Creamos tareas Rake personalizadas para futuras inspecciones

