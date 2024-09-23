---------------------------------------
------------- TABLA TEMPORAL
--DROP TABLE IF EXISTS ##VERIFICAR_FACTURAS_CURSOR

 IF OBJECT_ID('tempdb..##VERIFICAR_FACTURAS_CURSOR') IS NOT NULL  
 BEGIN  
   DROP TABLE ##VERIFICAR_FACTURAS_CURSOR
 END

-- PARA VERIFICAR CUALES TIENEN ESTADO 0 Y SIN DESCRIPCION EN CENTRAL
--SELECT A.*, 
SELECT A.U_TIENDA, B.DIRECCIONIP, B.NOMBRECORTO, A.U_SERIE, A.U_NUMERO, A.AUTORIZACION, A.RECLAMO, A.FECHA, 
	CONCAT('DECLARE @RECLAMO VARCHAR(10)
	
	SELECT COMMENTS, U_SERIE, U_NUMERO, U_NOM, U_FECHA 
	FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TRI_FACTURAS]
	WHERE U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+'
	AND U_SERIE = '''+A.U_SERIE+'''
	SELECT @RECLAMO = SUBSTRING(COMMENTS, PATINDEX(''%RECLAMO:%'', COMMENTS)+9 , PATINDEX(''% ]%'', COMMENTS)-PATINDEX(''%RECLAMO:%'', COMMENTS)-9)
	FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TRI_FACTURAS]
	WHERE U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+'
	AND U_SERIE = '''+A.U_SERIE+'''
	
	SELECT @RECLAMO AS RECLAMO
	',
	'UPDATE [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TBL_FACTURA_OSIGU]
	SET RECLAMO = @RECLAMO
	WHERE U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+' AND U_SERIE = '''+A.U_SERIE+'''
	',
	'UPDATE ['+B.DIRECCIONIP+'].['+B.db_genesis+'].[VENTAS].[TBL_FACTURA_OSIGU]
	SET RECLAMO = @RECLAMO
	WHERE U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+' AND U_SERIE = '''+A.U_SERIE+'''
	',
	'SELECT * FROM ['+B.DIRECCIONIP+'].['+B.db_genesis+'].[VENTAS].[TBL_FACTURA_OSIGU] 
	WHERE FECHA > CAST (GETDATE()-30 AS DATE) 
	AND U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+'
	AND U_SERIE = '''+A.U_SERIE+'''
	ORDER BY FECHA DESC') AS PROCESOS_DE_ACTUALIZACION
INTO ##VERIFICAR_FACTURAS_CURSOR
FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TBL_FACTURA_OSIGU] A
	INNER JOIN PRODUCCION.TBL_TIENDAS B
	ON A.U_TIENDA = B.U_TIENDA
WHERE A.ESTADO = 0
AND A.FECHA > CAST (GETDATE()-30 AS DATE) 
AND RECLAMO IS NULL OR RECLAMO = 0 
ORDER BY A.FECHA ASC


SELECT * FROM  ##VERIFICAR_FACTURAS_CURSOR
ORDER BY FECHA ASC

---------------------------------------------------------------
-------- ** CURSOR PARA EJECUTAR REGISTROS
DECLARE	@U_TIENDA		SMALLINT, 
		@IP_SERVIDOR	NVARCHAR(15), 
		@NOMBRECORTO		VARCHAR(100),
		@RESULT			INT,
		@SQLStringPing		VARCHAR(100),
		@Contador SMALLINT = 0,
		@RegExistentes smallint
-- VALIDAR CANTIDAD DE REGISTROS
DECLARE @CantRegistros INT = (SELECT COUNT(U_TIENDA) FROM  ##VERIFICAR_FACTURAS_CURSOR)
IF(@CantRegistros = 0)
	BEGIN
		SELECT 'NO HAY REGISTROS PARA ACTUALIZAR'
	END
ELSE
BEGIN
	BEGIN TRY 
	--BEGIN TRANSACTION
	SELECT CONCAT('Hay ', @CantRegistros, ' registro(s) sin Reclamo')
		IF CURSOR_STATUS('global','C_TIENDAS_FAC') = 1
		BEGIN
		 DEALLOCATE C_TIENDAS_FAC
		END

		DECLARE @SQLString NVARCHAR(MAX)
		DECLARE C_TIENDAS_FAC CURSOR FOR
			SELECT PROCESOS_DE_ACTUALIZACION, 
				U_TIENDA, 
				DIRECCIONIP,
				NOMBRECORTO
			FROM  ##VERIFICAR_FACTURAS_CURSOR
		OPEN C_TIENDAS_FAC
		FETCH NEXT FROM C_TIENDAS_FAC INTO @SQLString, @U_TIENDA, @IP_SERVIDOR, @NOMBRECORTO
		WHILE (@@FETCH_STATUS=0)
			BEGIN
				-- VALIDAR SI HAY ENLACE
				SET @SQLStringPing =  ' ping ' + @IP_SERVIDOR					
				EXEC @RESULT = xp_cmdshell  @SQLStringPing, no_output
				-- SI HAY ENLACE EJECUTA LOS QUERYS
				If  @RESULT = 0     -- NO HAY ENLACE @RESULT = 1 ;   @RESULT = 0 SI HAY ENLACE
				BEGIN
					PRINT CONCAT('LA TIENDA ', @U_TIENDA,' ',@NOMBRECORTO,' SI TIENE ENLACE') 
					--SELECT @SQLString AS PROCESOS_DE_ACTUALIZACION

					BEGIN TRY 
						EXECUTE sp_executesql @SQLString
						SET @Contador += 1
					END TRY 
					BEGIN CATCH
						SELECT 'HUBO UN ERROR AL REALIZAR PROCESO' AS ALERTA, ERROR_NUMBER() as ErrorNumero, ERROR_MESSAGE() as MensajeDeError
					END CATCH
				END
				-- SI NO HAY ENLACE NO EJECUTA
				ELSE IF  @RESULT = 1
					BEGIN
						PRINT CONCAT('LA TIENDA ', @U_TIENDA,' ', @NOMBRECORTO,' NO TIENE ENLACE')
				END
   
				FETCH NEXT FROM C_TIENDAS_FAC INTO @SQLString, @U_TIENDA, @IP_SERVIDOR, @NOMBRECORTO
			END
		CLOSE C_TIENDAS_FAC
		DEALLOCATE C_TIENDAS_FAC

		SELECT @RegExistentes = COUNT(U_NUMERO) FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TBL_FACTURA_OSIGU]
			WHERE ESTADO = 0 
			AND FECHA > CAST (GETDATE()-30 AS DATE) 
			AND RECLAMO IS NULL OR RECLAMO = 0 

		SELECT @RegExistentes AS 'Registros pendientes' 
		
		SELECT CONCAT('Se procesaron ', @Contador, ' registros') AS RESULTADO
	--COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		--ROLLBACK TRANSACTION;
		-- SELECT 'HUBO UN ERROR AL REALIZAR PROCESO' AS ALERTA, ERROR_NUMBER() as ErrorNumero,ERROR_MESSAGE() as MensajeDeError
		SELECT CONCAT('HUBO UN ERROR AL REALIZAR PROCESO EN: ', @SQLString) AS ALERTA
	END CATCH
END	
--------------------------------------------------

------ NOTAS 
-- AGREGAR VALIDACIONES DE CANTIDAD DE REGISTRO
-- AGREGAR MANEJO DE EXECPCIONES


--SELECT CURSOR_STATUS('global','C_TIENDAS_FAC') AS 'After declare'  
--OPEN C_TIENDAS_FAC  
--SELECT CURSOR_STATUS('global','C_TIENDAS_FAC') AS 'After Open'  
--CLOSE C_TIENDAS_FAC  
--SELECT CURSOR_STATUS('global','C_TIENDAS_FAC') AS 'After Close' 




--- PARA SETEAR CANTIDAD DE REGISTROS PENDIENTES
DECLARE @RegExistentes smallint

SELECT @RegExistentes = COUNT(U_NUMERO) FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TBL_FACTURA_OSIGU]
WHERE ESTADO = 0 
AND FECHA > CAST (GETDATE()-30 AS DATE) 
AND RECLAMO IS NULL OR RECLAMO = 0 

SELECT @RegExistentes


SELECT TOP 5 * FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TBL_FACTURA_OSIGU]
WHERE ESTADO = 0



	SELECT top 1 * FROM VENTAS.TRI_FACTURAS_XML WHERE U_NUMERO = 20931
	AND U_SERIE = 'FESCV216D           '