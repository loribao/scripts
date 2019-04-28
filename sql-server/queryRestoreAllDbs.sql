--loribao
--27/04/2019

-- Deixe todos os bkps na pasta e o restore começa
-- certifiquece que os nomes logicos correspondem ao nome fisico, ou se possui algum padrão é só ajustar na query deste script logo abaixo
USE master;  
GO
EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
RECONFIGURE;  
GO  
declare @baseDeDados table(id int identity(1,1) ,query varchar(max));
declare @baseDeDadosXp_CMDSHELL table(id int identity(1,1) ,nome varchar(max));
declare @diretorioBKP sysname, @comando sysname;
declare @mdf varchar(200), @ldf varchar(200);
select @diretorioBKP ='C:\bkps\';
select @comando = concat('powershell;cd ',@diretorioBKP,';[string[]](ls).Name')

--Obtem todas as bases de bkp
insert @baseDeDadosXp_CMDSHELL(nome)
exec master..xp_cmdshell @comando ;

-- gera a query de backup;
insert @baseDeDados(query)
(SELECT
--Query para fazer o restore dos bkp's nos diretorio C:\mdf\ e C:\ldf\  
'RESTORE DATABASE ['+nome+'] 
FROM  DISK = N'''+@diretorioBKP+nome+''' 
WITH  FILE = 1,  MOVE N'''+nome+''' 
TO N''C:\mdf\'+nome+'.mdf'',  
MOVE N'''+nome+'_log'' TO N''C:\ldf\'+nome+'_log.ldf''
,NOUNLOAD,  REPLACE,  STATS = 5'
from
	 @baseDeDadosXp_CMDSHELL
	 )

--executa restore um a um das bases;
declare @query varchar(max);
declare @NumeroDeQuery int;
declare @contador int;

--
set @contador = 1;
select @NumeroDeQuery = count(*) from @baseDeDados
--

while @contador <= @NumeroDeQuery
begin 
	select @query = query from @baseDeDados where id = @contador;
	exec(@query)
	set @contador = @contador + 1
end
GO

GO
EXEC sp_configure 'show advanced options', 0;  
GO  
RECONFIGURE;  
GO  

