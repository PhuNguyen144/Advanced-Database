--1. Ngày mượn sách phải là ngày hiện tại
--             T   X   S
--PhieuMuon    +   -   +(ngaymuon)

CREATE
TRIGGER q1
ON PhieuMuon
FOR INSERT,UPDATE
AS
BEGIN
	IF UPDATE(ngaymuon)
	BEGIN
		IF exists(SELECT pm.mapm
				  FROM inserted i join PhieuMuon pm ON i.mapm=pm.mapm
				  WHERE pm.ngaymuon=getdate())
		BEGIN
			RAISERROR(N'Ngày mượn phải là ngày hiện tại',15,1)
			ROLLBACK
		END
	END	
END
go
INSERT INTO PhieuMuon(mapm,madg,ngaymuon) VALUES('PM103','DG01','2023-03-09')

SELECT * FROM PhieuMuon

--2. Ngày trả sách phải là ngày hiện tại.
--             T   X   S
--PhieuTra     +   -   +	(ngaytra)

CREATE
TRIGGER q2
ON PhieuTra
FOR INSERT,UPDATE
AS
BEGIN
	IF UPDATE(ngaytra)
	BEGIN
		IF exists(SELECT pt.mapt
				  FROM inserted i join PhieuTra pt ON i.mapt=pt.mapt
				  WHERE pt.ngaytra=getdate())
		BEGIN
			RAISERROR(N'Ngày trả phải là ngày hiện tại',15,1)
			ROLLBACK
		END
	END	
END
go
INSERT INTO PhieuTra(mapt,mapm,ngaytra) VALUES('PT004','PM005','2023-03-09')

SELECT * FROM PhieuTra

--3. Tình trạng sách chỉ bao gồm : “đang được mượn” hoặc “có thể cho mượn”
--             T   X   S
--CuonSach     +   -   +	(tinhtrang)

CREATE
TRIGGER q3
ON CuonSach
FOR INSERT,UPDATE
AS 
BEGIN
	IF UPDATE(tinhtrang)
	BEGIN
		IF not exists(SELECT isbn
					  FROM inserted  
				      WHERE tinhtrang=N'đang được mượn' or tinhtrang=N'có thể cho mượn')
		BEGIN
			RAISERROR(N'tình trạng chỉ bao gồm "đang được mượn" hoặc "có thể mượn"',15,1)
			ROLLBACK
		END
	END	
END
go
INSERT INTO CuonSach(isbn,masach,tinhtrang) VALUES('116525441','S012',N'có thể cho mượn')

SELECT * FROM CuonSach
--4. Đọc giả muốn mượn sách phải từ 18 tuổi trở lên.
--           T   X   S
--DocGia     +   -   +	(ngsinh)

CREATE
TRIGGER q4
ON DocGia
FOR INSERT,UPDATE 
AS
BEGIN
	IF UPDATE(ngsinh)
	BEGIN
		IF not exists(SELECT madg
					  FROM inserted 
					  WHERE abs(datediff(year, getdate(), ngsinh))>18)	
		BEGIN
			RAISERROR (N'Độc giả phải trên 18 tuổi',15,1)
			ROLLBACK
		END
	END	
END
go
INSERT INTO DocGia(madg,hoten,ngsinh) VALUES('DG11',N'Nguyễn Huy Hoàng','2/9/2020')

--5. Số lượng đầu sách hiện có >=0.
--           T   X   S
--DauSach    +   -   +	(soluong)

CREATE
TRIGGER q5
ON DauSach
FOR INSERT,UPDATE
AS 
BEGIN
	IF UPDATE(soluong)
	BEGIN
		IF not exists(SELECT isbn
					  FROM inserted 
					  WHERE soluong>=0)
		BEGIN
			RAISERROR(N'Số lượng đầu sách phải lớn hơn hoặc bằng 0',15,1)
			ROLLBACK
		END
	END	
END
go
INSERT INTO DauSach(isbn,tensach,soluong)
VALUES('22345678',N'Hướng dẫn ném smoke','-1')

SELECT * FROM DauSach
--6. Thêm thuộc tính “SoLanTra” vào bảng PhieuMuon. SoLantra = số phiếu trả của phiếu mượn tương ứng
--		       T   X   S
--PhieuMuon    +   -   -	(SoLanTra)
CREATE
TRIGGER q6
FOR INSERT, UPDATE, DELETE
AS 
BEGIN
	IF not exists (SELECT * 
				   FROM inserted i join PhieuTra pt ON i.mapm = pt.mapm
				   WHERE count (distinct mapt) = SoLanTra)
	BEGIN 
		RAISERROR(N'Thao tác đã bị hủy',15,1);
		ROLLBACK TRANSACTION
	END 
END

SELECT * FROM PhieuMuon
SELECT * FROM PhieuTra


--7. Thêm thuộc tính “NgayTraDuKien” vào bảng CT_PhieuTra. Ngày trả dự kiến = ngày mượn +
--số ngày quy định được mượn.

--               T   X   S
--CT_PhieuTra    +   -   -
--        (NgayTraDuKien)
--8. Tình trạng cuốn sách được tự động cập nhật “đang được mượn” khi thủ thư thực hiện cho độc
--giả mượn sách này.