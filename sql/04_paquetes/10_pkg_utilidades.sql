-- Paquete 10/10: utilidades (funciones de apoyo reutilizadas por los demas paquetes)
-- Ejecutar con: isql-fb -user SYSDBA -password '<password_sysdba>' localhost:/var/lib/firebird/data/vivero_nativacr.fdb -i 10_pkg_utilidades.sql

SET TERM ^ ;

CREATE PACKAGE pkg_utilidades
SQL SECURITY DEFINER
AS
BEGIN
  FUNCTION fn_formatear_moneda(monto DECIMAL(12,2)) RETURNS VARCHAR(30);
  FUNCTION fn_validar_estado_lote(estado VARCHAR(12)) RETURNS BOOLEAN;
END^

CREATE PACKAGE BODY pkg_utilidades
AS
BEGIN
  FUNCTION fn_formatear_moneda(monto DECIMAL(12,2)) RETURNS VARCHAR(30)
  AS
    DECLARE VARIABLE v_str VARCHAR(20);
    DECLARE VARIABLE v_entero VARCHAR(20);
    DECLARE VARIABLE v_decimal VARCHAR(2);
    DECLARE VARIABLE v_punto INTEGER;
    DECLARE VARIABLE v_con_comas VARCHAR(24);
    DECLARE VARIABLE v_len INTEGER;
    DECLARE VARIABLE v_i INTEGER;
    DECLARE VARIABLE v_contador INTEGER;
    DECLARE VARIABLE v_ch CHAR(1);
  BEGIN
    v_str = CAST(monto AS VARCHAR(20));
    v_punto = POSITION('.', v_str);

    IF (v_punto > 0) THEN
    BEGIN
      v_entero = SUBSTRING(v_str FROM 1 FOR v_punto - 1);
      v_decimal = SUBSTRING(v_str FROM v_punto + 1 FOR 2);
    END
    ELSE
    BEGIN
      v_entero = v_str;
      v_decimal = '00';
    END

    v_len = CHAR_LENGTH(v_entero);
    v_con_comas = '';
    v_contador = 0;
    v_i = v_len;

    WHILE (v_i >= 1) DO
    BEGIN
      v_ch = SUBSTRING(v_entero FROM v_i FOR 1);
      v_con_comas = v_ch || v_con_comas;
      v_contador = v_contador + 1;
      IF (v_contador = 3 AND v_i > 1) THEN
      BEGIN
        v_con_comas = ',' || v_con_comas;
        v_contador = 0;
      END
      v_i = v_i - 1;
    END

    RETURN 'C ' || v_con_comas || '.' || v_decimal;
  END

  FUNCTION fn_validar_estado_lote(estado VARCHAR(12)) RETURNS BOOLEAN
  AS
  BEGIN
    RETURN estado IN ('activo', 'vendido', 'descartado');
  END
END^

SET TERM ; ^

COMMIT;
