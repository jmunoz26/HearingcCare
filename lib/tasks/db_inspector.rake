namespace :db do
  desc "Inspecciona la estructura de la base de datos y muestra información detallada"
  task inspect: :environment do
    puts "\n" + "=" * 80
    puts "INSPECCIÓN DE BASE DE DATOS"
    puts "=" * 80

    tables = ActiveRecord::Base.connection.tables.reject do |table|
      ['schema_migrations', 'ar_internal_metadata'].include?(table)
    end

    tables.each do |table|
      puts "\n" + "-" * 80
      puts "Tabla: #{table}"
      puts "-" * 80

      columns = ActiveRecord::Base.connection.columns(table)
      
      # Información de columnas
      puts "\nColumnas:"
      columns.each do |col|
        type_info = "#{col.type}"
        type_info += " (#{col.limit})" if col.limit
        null_info = col.null ? "NULL" : "NOT NULL"
        default_info = col.default ? "DEFAULT: #{col.default}" : ""
        
        puts "  #{col.name.ljust(25)} #{type_info.ljust(20)} #{null_info.ljust(10)} #{default_info}"
      end

      # Detectar foreign keys
      foreign_keys = ActiveRecord::Base.connection.foreign_keys(table)
      if foreign_keys.any?
        puts "\nForeign Keys:"
        foreign_keys.each do |fk|
          puts "  #{fk.column} -> #{fk.to_table}.#{fk.primary_key}"
        end
      end

      # Detectar índices
      indexes = ActiveRecord::Base.connection.indexes(table)
      if indexes.any?
        puts "\nÍndices:"
        indexes.each do |idx|
          unique = idx.unique ? "UNIQUE" : ""
          puts "  #{idx.name.ljust(40)} #{unique.ljust(10)} (#{idx.columns.join(', ')})"
        end
      end

      # Generar comando scaffold sugerido
      scaffold_attrs = columns.reject { |c| ['id', 'created_at', 'updated_at'].include?(c.name) }
                              .map { |c| "#{c.name}:#{column_type_for_scaffold(c)}" }
                              .join(' ')
      
      model_name = table.singularize.camelize
      puts "\nComando scaffold sugerido:"
      puts "  rails g scaffold #{model_name} #{scaffold_attrs}"
    end

    puts "\n" + "=" * 80
    puts "Inspección completada"
    puts "=" * 80 + "\n"
  end

  desc "Genera comentarios de esquema para los modelos (similar a annotate)"
  task annotate_models: :environment do
    Dir.glob(Rails.root.join('app/models/**/*.rb')).each do |file|
      model_name = File.basename(file, '.rb').camelize
      
      begin
        model = model_name.constantize
        next unless model < ActiveRecord::Base
        
        table_name = model.table_name
        columns = ActiveRecord::Base.connection.columns(table_name)
        
        # Generar comentario
        comment = generate_schema_comment(table_name, columns)
        
        # Leer archivo actual
        content = File.read(file)
        
        # Remover comentarios antiguos si existen
        content = content.gsub(/^# == Schema Information.*?^#\n/m, '')
        
        # Agregar nuevo comentario
        new_content = comment + "\n" + content
        
        # Escribir archivo
        File.write(file, new_content)
        
        puts "✓ Anotado: #{file}"
      rescue => e
        puts "✗ Error en #{file}: #{e.message}"
      end
    end
    
    puts "\n✅ Modelos anotados exitosamente"
  end

  private

  def self.column_type_for_scaffold(column)
    case column.type
    when :integer
      column.name.end_with?('_id') ? 'references' : 'integer'
    when :datetime, :timestamptz
      'datetime'
    when :text
      'text'
    when :boolean
      'boolean'
    when :decimal
      'decimal'
    when :date
      'date'
    when :uuid
      column.name.end_with?('_id') ? 'references' : 'uuid'
    else
      column.type.to_s
    end
  end

  def self.generate_schema_comment(table_name, columns)
    comment = "# == Schema Information\n"
    comment += "#\n"
    comment += "# Table name: #{table_name}\n"
    comment += "#\n"
    
    columns.each do |col|
      type_str = "#{col.type}"
      type_str += "(#{col.limit})" if col.limit
      null_str = col.null ? "" : ", not null"
      default_str = col.default ? ", default: #{col.default}" : ""
      
      comment += "#  #{col.name.ljust(20)} :#{type_str}#{null_str}#{default_str}\n"
    end
    
    comment += "#\n"
    comment
  end
end

