--7--
GO
CREATE PROC TongGiaTri @n int, @m int, @result int out
AS 
SET @result = 0
WHILE(@n <= @m)
BEGIN
    SET @result +=@n
    SET @n +=1
END
GO
DECLARE @result int
EXEC TongGiaTri 1,10,@result out
PRINT @result

--8--
GO
CREATE PROC TinhNamNhuan @n int, @result int out
AS 
BEGIN
    if(@n %4=0 or @n %100=0 and @n % 400=0)
        SET @result=1
    else
        SET @result=0
END
GO 
DECLARE @result int 
EXEC TinhNamNhuan 2008, @result out
PRINT @result

--9--
GO
CREATE PROC DemNamNhuan @n int, @m int, @result int out
AS
SET @result=0
WHILE (@n <= @m)
BEGIN
    if(@n%4=0 or @n%100=0 and @n%400=0)
        SET @result +=1
    SET @n +=1
END 
GO 
DECLARE @result int
EXEC DemNamNhuan 2000, 2050, @result out
PRINT @result

--10--
GO
CREATE PROC TinhGiaiThua @n int, @result int out
AS
DECLARE @m int=1
SET @result = 1
WHILE(@m <= @n)
BEGIN
    SET @result *= @m
    SET @m += 1
END
GO
DECLARE @result int
EXEC TinhGiaiThua 7, @result out
PRINT @result