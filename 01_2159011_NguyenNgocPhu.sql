--01  2159011  Nguyễn Ngọc Phú--
--1--

-- CHECKING AND DROP THE FUNCTION IF IT EXIST--
IF OBJECT_ID('UF_D1_C1') IS NOT NULL
	DROP FUNCTION UF_D1_C1
GO
CREATE FUNCTION UF_D1_C1(@MaGV VARCHAR(15))
RETURNS INT 
	BEGIN     
		DECLARE @result INT;      
		SELECT @result = COUNT(MaDT)
		FROM GiangVien gv JOIN DeTaiNCC dtnc ON dtnc.ChuNhiemDT = gv.MaGV     
		WHERE @MaGV = gv.MaGV AND dtnc.XepLoai IS NULL     
		RETURN @result      
	END 
SELECT dbo.UF_D1_C1('GV03')
	
		



--2--
--			T  X  S 
--DeTaiNNC: +  -  + (ChuNhiemDT)


-- CHECKING AND DROP THE FUNCTION IF IT EXIST--
IF OBJECT_ID('UTR_D1_2') IS NOT NULL
	DROP TRIGGER UTR_D1_2
GO
CREATE TRIGGER UTR_D1_2 ON DeTaiNCC
FOR INSERT
AS	
BEGIN 
	IF NOT EXISTS (SELECT *
					FROM inserted i JOIN DeTaiNCC dtnc ON i.MaDT = dtnc.MaDT AND i.MaNNC = dtnc.MaNNC
					WHERE dbo.UF_D1_C1(dtnc.ChuNhiemDT) = 1)
	BEGIN
		RAISERROR('ERROR', 15, 1)
		ROLLBACK TRANSACTION
	END
END

GO
INSERT INTO DeTaiNCC(MaDT, MaNNC, ChuNhiemDT, XepLoai) VALUES ('2022.CNTT.04', 'NH02', 'GV05', NULL)



--3--

-- CHECKING AND DROP THE FUNCTION IF IT EXIST--
IF OBJECT_ID('UTR_D1_C3') IS NOT NULL
	DROP TRIGGER UTR_D1_C3
GO
CREATE TRIGGER UTR_D1_C3 ON DeTaiNCC
FOR INSERT, UPDATE
AS	
BEGIN 
	IF UPDATE(ChuNhiemDT)
		IF NOT EXISTS (SELECT *
						FROM inserted i
						WHERE dbo.UF_D1_C1(i.ChuNhiemDT) = 1)
	BEGIN
		DECLARE @MaGV varchar(15)

		SELECT TOP 1 @MaGV = MaGV
		FROM GiangVien gv
		WHERE gv.MaGV NOT IN (SELECT dtnc.ChuNhiemDT
								FROM DeTaiNCC dtnc
								WHERE XepLoai IS NULL)
	
		IF (@MaGV IS NULL)
			BEGIN 
				UPDATE DeTaiNCC
				SET ChuNhiemDT = @MaGV
				FROM inserted i
				WHERE DeTaiNCC.MaDT = i.MaDT AND DeTaiNCC.MaNNC = i.MaNNC
			END
		ELSE
			BEGIN
				UPDATE DeTaiNCC
				SET ChuNhiemDT = @MaGV
				FROM inserted i
				WHERE DeTaiNCC.MaDT = i.MaDT AND DeTaiNCC.MaNNC = i.MaNNC
			END
				
	END
END
GO