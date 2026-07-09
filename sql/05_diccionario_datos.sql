-- Diccionario de datos - Firebird
-- Alternativa a SQL Developer (pensado para Oracle): esta consulta lee los
-- catalogos del sistema de Firebird (RDB$RELATIONS, RDB$RELATION_FIELDS,
-- RDB$FIELDS) y genera el listado de columnas de las 8 tablas del modelo.
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 05_diccionario_datos.sql

SELECT
    TRIM(rf.rdb$relation_name)                       AS tabla,
    rf.rdb$field_position + 1                        AS posicion,
    TRIM(rf.rdb$field_name)                           AS columna,
    CASE f.rdb$field_type
      WHEN 7   THEN 'SMALLINT'
      WHEN 8   THEN 'INTEGER'
      WHEN 10  THEN 'FLOAT'
      WHEN 12  THEN 'DATE'
      WHEN 13  THEN 'TIME'
      WHEN 14  THEN 'CHAR(' || (f.rdb$field_length / NULLIF(cs.rdb$bytes_per_character, 0)) || ')'
      WHEN 16  THEN CASE f.rdb$field_sub_type
                       WHEN 1 THEN 'NUMERIC(' || f.rdb$field_precision || ',' || (-f.rdb$field_scale) || ')'
                       WHEN 2 THEN 'DECIMAL(' || f.rdb$field_precision || ',' || (-f.rdb$field_scale) || ')'
                       ELSE 'BIGINT'
                     END
      WHEN 27  THEN 'DOUBLE PRECISION'
      WHEN 35  THEN 'TIMESTAMP'
      WHEN 37  THEN 'VARCHAR(' || (f.rdb$field_length / NULLIF(cs.rdb$bytes_per_character, 0)) || ')'
      WHEN 261 THEN 'BLOB'
      ELSE 'OTRO (' || f.rdb$field_type || ')'
    END                                                AS tipo_dato,
    CASE WHEN rf.rdb$null_flag = 1 THEN 'NO' ELSE 'SI' END AS admite_nulo,
    rf.rdb$default_source                             AS valor_por_defecto
FROM rdb$relation_fields rf
JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source
JOIN rdb$relations r ON r.rdb$relation_name = rf.rdb$relation_name
LEFT JOIN rdb$character_sets cs ON cs.rdb$character_set_id = f.rdb$character_set_id
WHERE r.rdb$system_flag = 0
  AND r.rdb$view_blr IS NULL
ORDER BY rf.rdb$relation_name, rf.rdb$field_position;
