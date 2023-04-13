--1--
CREATE 
--alter
FUNCTION c1()
RETURNS int
AS
BEGIN
     DECLARE @sodocgia int
	 SELECT @sodocgia= count(madg)
	 FROM DocGia
	 RETURN @sodocgia
END

SELECT dbo.c1()

--2--
CREATE 
--alter
FUNCTION c2(@isbn nchar(12))
RETURNS float
AS
BEGIN
	IF not exists (SELECT *
                   FROM DauSach
                   WHERE isbn=@isbn)
        RETURN -1;

    DECLARE @mucgiaphat float
	SELECT @mucgiaphat =mucgiaphat
	FROM DauSach
	WHERE isbn=@isbn
	RETURN @mucgiaphat
END

SELECT dbo.c2('116525441')

--3--
CREATE
--alter
FUNCTION c3 (@mapm varchar(20), @isbn varchar(20), @masach varchar(20))
RETURNS int
AS
BEGIN
	IF not exists (SELECT *
                   FROM CT_PhieuMuon
                   WHERE mapm=@mapm and isbn=@isbn and masach=@masach)
        RETURN -1;

	DECLARE @songayquidinh int
	SELECT @songayquidinh= ctpm.songayquydinh
	FROM CT_PhieuMuon ctpm inner join PhieuMuon pm ON ctpm.mapm=pm.mapm
	WHERE ctpm.mapm=@mapm and ctpm.isbn=@isbn and ctpm.masach=@masach
	RETURN @songayquidinh
END

SELECT dbo.c3('PM001','116525441','S001')

--4--
CREATE 
--alter
FUNCTION c4(@mapm varchar(20))
RETURNS date
AS
BEGIN
	IF not exists (SELECT *
                   FROM PhieuMuon
                   WHERE mapm=@mapm)
        RETURN getdate();

	DECLARE @ngaymuon date
	SELECT @ngaymuon=ngaymuon
	FROM PhieuMuon
	WHERE mapm=@mapm
	RETURN @ngaymuon
END

SELECT dbo.c4('PM001')

--5--
CREATE
--alter
FUNCTION c5(@mapt varchar(30))
RETURNS date
AS
BEGIN
	IF not exists (SELECT *
                   FROM PhieuTra
                   WHERE mapt=@mapt)
        RETURN getdate();

	DECLARE @ngaytra date
	SELECT @ngaytra=ngaytra
	FROM PhieuTra
	WHERE mapt=@mapt
	RETURN @ngaytra
END

SELECT dbo.c5('PT001')

--9--
CREATE 
--alter
FUNCTION c9(@ngaymuon date)
RETURNS int
AS
BEGIN
	IF not exists (SELECT *
                   FROM PhieuMuon
                   WHERE ngaymuon=@ngaymuon)
        RETURN -1;

	DECLARE @sosach int
	SELECT DISTINCT @sosach=count(*)
	FROM PhieuMuon 
	WHERE ngaymuon=@ngaymuon
	RETURN @sosach
END

SELECT dbo.c9('2014-12-20')
 
--10--
CREATE
--alter 
FUNCTION c10(@mapm char(10), @mapt char(10))
RETURNS int
AS
BEGIN
	IF not exists (SELECT *
                   FROM PhieuMuon
                   WHERE mapm=@mapm)
        RETURN -1;

	IF not exists (SELECT *
                   FROM PhieuTra
                   WHERE mapt=@mapt)
        RETURN -1;

	DECLARE @sosachno int
	SELECT @sosachno = count(pm.mapm)-1
	FROM PhieuMuon pm join PhieuTra pt ON pm.mapm=pt.mapm
	WHERE pt.mapt=@mapt and pm.mapm=@mapm and pm.mapm in (SELECT mapm 
														  FROM PhieuTra
													      WHERE mapt=@mapm and mapt=@mapt)
	RETURN @sosachno
END

SELECT dbo.c10('PM001', 'PT001')


--11--
CREATE 
--alter
FUNCTION c11(@mapt char(10) , @isbn nchar(12) , @masach nchar(5))
RETURNS float
AS
BEGIN
	IF not exists (SELECT *
                   FROM CT_PhieuTra
                   WHERE mapt=@mapt and isbn=@isbn and masach=@masach)
        RETURN -1;

	DECLARE @tienphat float
	SELECT @tienphat=tienphat
	FROM CT_PhieuTra
	WHERE mapt=@mapt and isbn=@isbn and masach=@masach
	RETURN @tienphat
END

SELECT dbo.c11('PT001','116525441','S001')

--12--
CREATE 
--alter
FUNCTION c12(@isbn varchar(20),@status int)
RETURNS @bookList table(isbn varchar(20),masach varchar(10))
AS
BEGIN
	IF (@status=1)
	BEGIN
		INSERT INTO @bookList(isbn,masach)
		SELECT isbn,masach
		FROM CT_PhieuMuon
		WHERE isbn=@isbn
	END
	ELSE IF (@status=2)
	BEGIN
		INSERT INTO @bookList(isbn,masach)
		SELECT isbn,masach
		FROM CuonSach
		WHERE tinhtrang=N'có thể mượn' and isbn=@isbn
	END
	RETURN
END

SELECT * FROM dbo.c12('116525441',2)

--13--
CREATE
--alter 
FUNCTION c13 (@tinhtrang nchar(50))
RETURNS table
AS 
RETURN (SELECT isbn, masach, tinhtrang
		FROM CuonSach
		WHERE tinhtrang=@tinhtrang)

SELECT * FROM c13(N'có thể mượn')

--14--
CREATE
--alter
FUNCTION cau14 (@theloai nvarchar(70))
RETURNS table
AS 
RETURN (SELECT isbn,tensach, tacgia,soluong,mucgiaphat,theloai
		FROM DauSach
		WHERE theloai=@theloai)

SELECT * FROM c14 (N'ngoại ngữ')

--18--
CREATE 
--alter
FUNCTION cau18 (@isbn nchar(12) ,@masach nchar(5))
RETURNS table
AS
RETURN (SELECT DauSach.isbn, masach , count(mapm) AS sosachdangmuom,soluong AS sosachcon
        FROM CT_PhieuMuon join DauSach ON CT_PhieuMuon.isbn=DauSach.isbn
		GROUP BY DauSach.isbn,masach,soluong
		HAVING DauSach.isbn=@isbn and masach=@masach)

SELECT * FROM dbo.c18('116525441','S002')

--19--
CREATE
--alter
FUNCTION c19(@madg nchar(10))
RETURNS table
AS
RETURN(SELECT pm.mapm,pm.ngaymuon,count(*)AS SoSachMuon
       FROM PhieuMuon pm join CT_PhieuMuon ctpm ON pm.mapm=ctpm.mapm
       WHERE pm.madg=@madg
       GROUP BY pm.mapm,pm.ngaymuon)

SELECT * FROM c19('DG01')

--20--
CREATE
--alter
FUNCTION c20(@ngaymuon date)
RETURNS table
AS
RETURN (SELECT ctpm.mapm,ctpm.isbn,ctpm.masach,ctpm.songayquydinh
        FROM CT_PhieuMuon ctpm join PhieuMuon pm ON ctpm.mapm=pm.mapm
        WHERE pm.ngaymuon=@ngaymuon)

SELECT * FROM c20('2014-12-20')