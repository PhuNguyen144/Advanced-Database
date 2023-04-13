
--					T	X	S
--PhieuMuon			-	-	+

--ALTER TRIGGER tg_ThemPN
--ON PhieuMuon
--FOR INSERT 
--AS
--BEGIN
--	SELECT COUNT(*) FROM inserted i JOIN PhieuMuon pm ON pm.mapm = i.mapm
--	GROUP BY i.madg, i.ngaymuon
--END
--GO
--INSERT INTO PhieuMuon(mapm, madg, ngaymuon) VALUES ('PM2', 'DG01', '3/1/2022')


--4. Đọc giả muốn mượn sách phải từ 18 tuổi trở lên.--
SELECT * FROM DocGia
--					T	X	S
--DocGia			+	-	-

ALTER TRIGGER c4
ON DocGia
FOR INSERT, UPDATE 
AS
BEGIN
	IF NOT EXISTS (SELECT dg.madg
					FROM inserted i JOIN DocGia dg ON dg.madg = i.madg
					WHERE ABS(DATEDIFF(YEAR, GETDATE(), dg.ngsinh)) > 18)
	BEGIN
		RAISERROR ('DOC GIA PHAI TREN 18 TUOI - 18+', 15, 1)
		ROLLBACK 
	END
END
GO 
INSERT INTO DocGia(madg, hoten, ngsinh) VALUES ('DG09', N'Nguyễn Ngọc Phú', '4/14/2010')

--5. Số lượng đầu sách hiện có >=0.--
SELECT * FROM DauSach
--					T	X	S
--DauSach			+	-	-

ALTER TRIGGER c5
ON DauSach
FOR INSERT
AS
BEGIN
	IF NOT EXISTS (SELECT ds.isbn
				FROM inserted i JOIN DauSach ds ON ds.isbn = i.isbn
				WHERE ds.soluong >= 0)
	BEGIN
		RAISERROR ('SO LUONG DAU SACH >= 0', 15, 1)
		ROLLBACK 
	END
END
GO
INSERT INTO DauSach(isbn, tensach, soluong) VALUES ('22121212', N'IELTS 9.0', '-3')
INSERT INTO DauSach(isbn, tensach, soluong) VALUES ('22221212', N'Ngữ Văn 9', '3')


--6. Thêm thuộc tính “SoLanTra” vào bảng PhieuMuon. SoLantra = số phiếu trả của phiếu mượn tương ứng. --
SELECT * FROM PhieuMuon