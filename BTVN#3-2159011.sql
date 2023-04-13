--1--
CREATE PROC dgmp @mapm char(10)
AS
BEGIN
    IF NOT EXISTS (SELECT mapm 
					FROM PhieuMuON 
					WHERE mapm=@mapm)
		BEGIN
			RAISERROR('KhONg tON tai ma phieu muON',15,1)
			RETURN
		END
	ELSE
	BEGIN
        SELECT DISTINCT dg.socmnd,dg.hoten,dg.ngsinh,dg.diachi
        FROM  DocGia dg JOIN PhieuMuON pm ON dg.madg=pm.madg
        WHERE pm.mapm = @mapm
	END
END
GO 
EXEC dgmp 'PM001'

--2--
CREATE PROC ttdg @nam char(4)
AS
BEGIN
	IF NOT EXISTS (SELECT ngsinh
					FROM DocGia
					WHERE year(ngsinh) = @nam)
		BEGIN

			RAISERROR('KhONg co doc gia sinh nam nay',15,1)
			RETURN
		END
	ELSE
	BEGIN
		SELECT DISTINCT dg.socmnd,dg.hoten,dg.ngsinh,dg.diachi
        FROM  DocGia dg 
        WHERE year(ngsinh)=@nam
	END
END
GO 
EXEC ttdg '1990'

--3--
SELECT *
FROM DocGia dg
WHERE year(dg.ngsinh)>=ALL(SELECT year(ngsinh)
                           FROM DocGia)

--4--
CREATE PROC dgms @mapm char(10)
AS
BEGIN 
	IF NOT EXISTS (SELECT mapm
					FROM PhieuMuON
					WHERE mapm=@mapm)
		BEGIN
			RAISERROR('KhONg tON tai ma phieu muON',15,1)
			RETURN
		END
	ELSE
		BEGIN
			SELECT dg.socmnd,dg.hoten,count(ctpm.mapm) AS SoSachDuocMuON
            FROM  DocGia dg JOIN PhieuMuON pm ON dg.madg=pm.madg
                            JOIN CT_PhieuMuON ctpm ON ctpm.mapm=pm.mapm
			WHERE pm.mapm=@mapm
			GROUP BY dg.socmnd, dg.hoten
		END
END
GO 
EXEC dgms 'PM001'

--5--
CREATE PROC dsgd @isbn nchar(12)
AS 
BEGIN
    IF NOT EXISTS (SELECT isbn
                    FROM dausach
                    WHERE isbn=@isbn)
        BEGIN
            RAISERROR('KhONg tON tai ma sach',15,1)
            RETURN
        END
    ELSE
    BEGIN
        SELECT DISTINCT dg.socmnd,dg.hoten,dg.ngsinh,dg.diachi
        FROM  DocGia dg JOIN PhieuMuON pm ON dg.madg=pm.madg
                JOIN CT_PhieuMuON ctpm ON ctpm.mapm=pm.mapm
        WHERE ctpm.isbn = @isbn 
    END
END
GO
EXEC dsgd '116525441'

--6--
CREATE PROC ttcs @socmnd nchar(10)
AS
BEGIN
    IF NOT EXISTS (SELECT socmnd 
                   FROM DocGia 
                   WHERE socmnd=@socmnd)
    BEGIN
        RAISERROR ('KhONg TON Tai so cmnd',15,1)
        RETURN
    END 
    ELSE
    BEGIN
        SELECT DISTINCT ctpm.isbn, ctpm.mASach
        FROM DocGia dg JOIN PhieuMuON pm ON dg.madg=pm.madg
                        JOIN CT_PhieuMuON ctpm ON ctpm.mapm=pm.mapm
        WHERE dg.socmnd=@socmnd
    END
END
GO
EXEC ttcs '2157836254'

--7--
CREATE PROC slpt @mapm char(10)
AS
BEGIN
    IF NOT EXISTS (SELECT mapm 
				   FROM PhieuMuON 
				   WHERE mapm=@mapm)
    BEGIN
        RAISERROR ('KhONg TON Tai so cmnd',15,1)
        RETURN
    END 
    ELSE
    BEGIN
        SELECT count(ctpt.mapt) AS soluONgphieutra
        FROM PhieuMuON pm JOIN PhieuTra pt ON pm.mapm=pt.mapm 
							JOIN CT_PhieuTra ctpt ON ctpt.mapt=pt.mapt
        WHERE pm.mapm=@mapm
    END
END
GO
EXEC slpt 'PM001'

--9--
CREATE PROC cau9 @mapt char(10)
AS
BEGIN
IF NOT EXISTS(SELECT @mapt
			  FROM PhieuTra
			  WHERE mapt=@mapt )
			  RETURN 1
	update PhieuTra
	set ngaytra=getdate()
	WHERE mapt=@mapt

	update CT_PhieuTra
	set tienphat = mucgiaphat*(SELECT DISTINCT datedIFf(day,pm.ngaymuON,pt.ngaytra)-ctpm.sONgayquydinh
							   FROM PhieuTra pt JOIN PhieuMuON pm ON pt.mapm=pm.mapm 
							                    JOIN CT_PhieuMuON ctpm ON pm.mapm=ctpm.mapm)
	WHERE mapt=@mapt
END
GO
EXEC cau9 'PT007'

--10--
CREATE PROC ttpm @mapm char(10), @madg char(10)
AS
BEGIN
	IF exists(SELECT @mapm
			  FROM PhieuMuON 
			  WHERE mapm=@mapm )
			  RETURN 1			  
	IF (@madg is null) or NOT EXISTS (SELECT @madg
				     FROM DocGia
				     WHERE madg=@madg)
				     RETURN 2
	INSERT INTO PhieuMuON(mapm, madg, ngaymuON, SoLanTra)
	VALUES (@mapm,@madg,getdate(), null)
	RETURN 0
END
GO
DECLARE @tt int
EXEC @tt = ttpm 'PM020','DG20'