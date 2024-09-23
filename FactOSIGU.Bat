@ECHO OFF
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "AA=%dt:~2,2%"
set "AAAA=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%"
set "Min=%dt:~10,2%"
set "Seg=%dt:~12,2%"

set "Nombre_SQL=%AAAA%_%MM%_%DD%_%HH%_%Min%_%Seg%"

CLS
@ECHO EJECUTANDO CURSOR CON FACTURAS OSIGU.sql

sqlcmd -i "D:\Documentos\Bofasa\ISIDRO\FACTURAS_OSIGU\CURSOR_FACTURAS_OSIGU_BAT.sql" -S 192.200.9.131 -d DB_GENESIS_CENTRAL -U earango -P bofasatest@ -o "D:\Documentos\Bofasa\ISIDRO\FACTURAS_OSIGU\CON_BAT\LOGS\FacturasOSIGUExit_%Nombre_SQL%.txt"

@ECHO PROCESO DE FACTURAS OSIGU TERMINADO !!!




:: CLS
:: @ECHO EJECUTANDO CURSOR CON FACTURAS OSIGU.sql
:: sqlcmd -i "C:\Bofasa\ISIDRO\FACTURAS_OSIGU\CURSOR_FACTURAS_OSIGU_BAT.sql" -S 192.200.9.131 -d DB_GENESIS_CENTRAL -U earango -P bofasatest@
:: -o "C:\Bofasa\ISIDRO\FACTURAS_OSIGU\CON_BAT\LOGS\FacturasOSIGUExit_%Nombre_SQL%.txt"
:: @ECHO PROCESO DE FACTURAS OSIGU TERMINADO !!!
:: PAUSE