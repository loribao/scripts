-- loribao
-- 27/04/2019

USE master;  
GO  
declare @baseDeDados table(id int identity(1,1) ,query varchar(max));
declare @diretorio varchar(max);
set @diretorio ='/home/bkps/'
--Obtem todas as bases da instancia e gera a query de backup;
insert @baseDeDados(query)
(SELECT 
'BACKUP DATABASE ['+name+'] TO  DISK = N'''+@diretorio+name+''' WITH NOFORMAT, NOINIT,  NAME = N'''+name+'-Completo Banco de Dados Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10'
FROM sys.databases 
where name not in ('master','model','msdb','tempdb')
);

--executa beckup um a um das bases;
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