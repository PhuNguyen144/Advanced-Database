--5--
CREATE PROC SP_MuonSach_ISBN
        @MaISBN nvarchar(15)
AS
BEGIN
    IF not exists (SELECT isbn FROM CuonSach WHERE isbn = @MaISBN)
    BEGIN
        RAISERROR ('DATA DOES NOT EXIST',15,1)
        RETURN
    END
    ELSE
    BEGIN
        SELECT distinct dg.socmnd, dg.hoten, dg.ngsinh, dg.diachi
        FROM DocGia dg JOIN PhieuMuon pm ON dg.madg = pm.madg
                JOIN CT_PhieuMuon ctpm ON ctpm.mapm = pm.mapm
                JOIN CuonSach cs ON cs.isbn = ctpm.isbn
        WHERE cs.isbn = @MaISBN
    END
END
GO
EXEC SP_MuonSach_ISBN '116525441' 
DROP PROC SP_MuonSach_ISBN

--6--
GO
CREATE PROC sp_MuonSach_CMND
        @SoCMND nvarchar(15)
AS
BEGIN
    IF not exists (SELECT socmnd FROM DocGia WHERE socmnd = @SoCMND)
    BEGIN
        RAISERROR ('DATA DOES NOT EXIST',15,1)
        RETURN
    END
    ELSE
    BEGIN
        SELECT distinct cs.isbn, cs.masach
        FROM DocGia dg JOIN PhieuMuon pm ON dg.madg = pm.madg
                JOIN CT_PhieuMuon ctpm ON ctpm.mapm = pm.mapm
                JOIN CuonSach cs ON cs.isbn = ctpm.isbn
        WHERE dg.socmnd = @SoCMND
    END
END
GO
EXEC sp_MuonSach_CMND '2157836254' 
DROP PROC sp_MuonSach_CMND

--7--
GO
CREATE PROC sp_SoPhieu 
	@MaPhieu nvarchar(15)
AS 
BEGIN
	IF NOT EXISTS (SELECT mapm FROM PhieuMuon WHERE mapm = @MaPhieu)
	BEGIN
		RAISERROR ('DATA DOES NOT EXIST',15,1)
		RETURN
	END
	ELSE
	BEGIN
		SELECT COUNT (ctpt.mapt) as SoLuongPhieu
		FROM PhieuMuon pm JOIN PhieuTra pt ON pm.mapm=pt.mapm
						  JOIN CT_PhieuTra ctpt on ctpt.mapt = pt.mapt
		WHERE PM.mapm = @MaPhieu
	END
END
GO
EXEC sp_SoPhieu 'PM001'
DROP PROC sp_SoPhieu

--8--
