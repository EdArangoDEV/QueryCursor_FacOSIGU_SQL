
DROP TABLE ##VERIFICAR_FACTURAS

-- PARA VERIFICAR CUALES TIENEN ESTADO 0 Y SIN DESCRIPCION EN CENTRAL
--SELECT A.*, 
SELECT A.U_TIENDA, A.U_SERIE, A.U_NUMERO, A.AUTORIZACION, A.RECLAMO, 
	'DECLARE @RECLAMO VARCHAR(10)
	
	SELECT COMMENTS, U_SERIE, U_NUMERO, U_NOM, U_FECHA 
	FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TRI_FACTURAS]
	WHERE U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+'
	AND U_SERIE = '''+A.U_SERIE+'''
	SELECT @RECLAMO = SUBSTRING(COMMENTS, PATINDEX(''%RECLAMO:%'', COMMENTS)+9, PATINDEX(''% ]%'', COMMENTS)-PATINDEX(''%RECLAMO:%'', COMMENTS)-9)
	FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TRI_FACTURAS]
	WHERE U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+'
	AND U_SERIE = '''+A.U_SERIE+'''
	
	SELECT @RECLAMO AS RECLAMO
	' AS 'CONSULTA DE RECLAMO EN TRI FACT',
	'UPDATE [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TBL_FACTURA_OSIGU]
	SET RECLAMO = @RECLAMO
	WHERE U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+' AND U_SERIE = '''+A.U_SERIE+'''
	' AS 'AGREGAR RECLAMO A CENTRAL',
	'UPDATE ['+B.DIRECCIONIP+'].['+B.db_genesis+'].[VENTAS].[TBL_FACTURA_OSIGU]
	SET RECLAMO = @RECLAMO
	WHERE U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+' AND U_SERIE = '''+A.U_SERIE+'''
	' AS 'AGREGAR RECLAMO A TIENDA',
	'SELECT * FROM ['+B.DIRECCIONIP+'].['+B.db_genesis+'].[VENTAS].[TBL_FACTURA_OSIGU] 
	WHERE FECHA > CAST (GETDATE()-30 AS DATE) 
	AND U_NUMERO = '+CONVERT(VARCHAR(20),A.U_NUMERO)+'
	AND U_SERIE = '''+A.U_SERIE+'''
	ORDER BY FECHA DESC' AS CONSULTA_EN_TIENDA
INTO ##VERIFICAR_FACTURAS
FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TBL_FACTURA_OSIGU] A
	INNER JOIN PRODUCCION.TBL_TIENDAS B
	ON A.U_TIENDA = B.U_TIENDA
WHERE A.ESTADO = 0 
AND A.FECHA > CAST (GETDATE()-30 AS DATE) 
AND RECLAMO IS NULL OR RECLAMO = 0 
ORDER BY A.FECHA ASC

SELECT * FROM  ##VERIFICAR_FACTURAS

 
--WHERE RECLAMO IS NULL
ORDER BY FECHA ASC
---------------------------------------
---------------------------------------

-------------
---SUBSTRING(COMMENTS, CHARINDEX(''RECLAMO:'', COMMENTS)+9, 5)
-------------

-- PARA VERIFICAR CUALES TIENEN ESTADO 0 Y SIN DESCRIPCION EN TIENDA
SELECT * FROM [VENTAS].[TBL_FACTURA_OSIGU] 
WHERE FECHA > CAST (GETDATE()-30 AS DATE) 
AND U_NUMERO = 45285
AND U_SERIE = 'FESCV164C'
ORDER BY FECHA DESC


-- PARA VER LOS DETALLES DE TRI FACTURAS XML EN TIENDA
SELECT TOP 5 * FROM [VENTAS].[TRI_FACTURAS_XML]
WHERE U_TIENDA = 73
AND U_NUMERO = 407443



-- PARA VER LOS DETALLES DE TRI FACTURAS EN CENTRAL
SELECT COMMENTS, U_SERIE, U_NUMERO, U_NOM, U_FECHA 
FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TRI_FACTURAS]
WHERE U_NUMERO = 45285
AND U_SERIE = 'FESCV164C'



-- PARA VER LOS DETALLES DE TRI FACTURAS EN TIENDA 
SELECT COMMENTS, U_SERIE, U_NUMERO, U_NOM, U_FECHA 
FROM [VENTAS].[TRI_FACTURAS]
WHERE U_NUMERO = 45285
AND U_SERIE = 'FESCV164C'

SELECT TOP 5 * FROM [VENTAS].[TRI_FACTURAS]
WHERE U_NUMERO = 46775
AND U_TIENDA = 215


-- PARA HACER EL UPDATE DEL CAMPO RECLAMO EN TIENDA 
--UPDATE [VENTAS].[TBL_FACTURA_OSIGU]
SET RECLAMO = 5021
WHERE U_NUMERO = 45285 AND U_SERIE = 'FESCV164C'


-- PARA HACER EL UPDATE DEL CAMPO RECLAMO EN TIENDA 
--UPDATE [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TBL_FACTURA_OSIGU]
SET RECLAMO = 5021
WHERE U_NUMERO = 45285 AND U_SERIE = 'FESCV164C'




-- PARA VER LOS DETALLES DE TRI FACTURAS XML EN TIENDA
SELECT TOP 5 * FROM [VENTAS].[TRI_FACTURAS_XML]
WHERE U_TIENDA = 156 
AND U_SERIE = 'FESCV164C'
AND U_PAIS = 320
AND U_NUMERO = 45285
ORDER BY U_NUMERO DESC



---- PARA VER CAMPOS DE XML
SELECT * FROM [VENTAS].[TRI_FACTURAS_XML]  WHERE  U_TIENDA = 156 AND U_NUMERO = 45285
ORDER BY U_NUMERO DESC

SELECT TOP 1 U_TIENDA, U_SERIE, U_NUMERO, 
			datos.value('(CLAIMID)[1]','NVARCHAR(MAX)') RECLAMO_DE_FACT, 
			datos.value('(COMMENTS)[1]','NVARCHAR(MAX)') COMMENTS
FROM [VENTAS].[TRI_FACTURAS_XML] 
             CROSS
             APPLY ESTRUCTURA_XML.nodes('/FACTURAS/FACTURA/ENCABEZADO') Fc (datos)
WHERE  U_TIENDA = 156 AND U_NUMERO = 407443 
ORDER BY U_NUMERO desc


-----------------------
-- PRUEBA PARA OBTENER EL RECLAMO DE LA FACTURA
-----------------------

SELECT COMMENTS, SUBSTRING(COMMENTS, CHARINDEX('RECLAMO:', COMMENTS)+9, 4) AS RECLAMO, U_SERIE, U_NUMERO, U_NOM, U_FECHA
	FROM [192.200.9.131].[DB_GENESIS_CENTRAL].[VENTAS].[TRI_FACTURAS]
	WHERE U_NUMERO = 496382
	AND U_SERIE = 'FESCV133A          '




