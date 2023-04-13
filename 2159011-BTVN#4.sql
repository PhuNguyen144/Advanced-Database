--1--

ALTER TABLE PhieuMuon
    ADD SoCuonMuon int;

DECLARE CUR CURSOR FOR (SELECT MaPM, COUNT(*)
                        FROM CT_PhieuMuon
                        GROUP BY MaPM)
OPEN CUR
DECLARE @MaPM char(10), @socuonmuon int
FETCH NEXT FROM CUR into @MaPM, @socuonmuon
WHILE (@@FETCH_status=0)
BEGIN
        update PhieuMuon
        SET SoCuonMuon = @socuonmuon 
        WHERE MaPM = @MaPM
    FETCH NEXT FROM CUR into @MaPM, @socuonmuon
END
CLOSE CUR
DEALLOCATE CUR

--2--

CREATE PROC DS_DauSach @ISBN nchar(12)
AS
    DECLARE CUR CURSOR FOR(SELECT ct.isbn, tensach, COUNT(DISTINCT ct.masach) 
    AS SoSachMuon
	FROM DauSach JOIN CuonSach 
	ON DauSach.isbn = CuonSach.isbn JOIN CT_PhieuMuon  ct
	ON  ct.masach = CuonSach.masach AND ct.isbn = CuonSach.isbn
	WHERE DauSach.isbn = @ISBN
	GROUP BY ct.isbn, tensach)
	
	OPEN CUR
	DECLARE @TenSach nvarchar(25), @SoSachMuon int ,@SoSachConLai int
	FETCH NEXT FROM CUR into @ISBN, @TenSach, @SoSachMuon
	WHILE (@@FETCH_status = 0)
	BEGIN
	       
	       SELECT @SoSachConLai = (SELECT COUNT(cs.masach) AS sig FROM CuonSach cs JOIN CT_PhieuMuon ct ON cs.isbn = ct.isbn AND cs.masach = ct.masach
			WHERE  cs.isbn = '116525441' AND cs.masach 
			NOT IN (SELECT DISTINCT masach FROM CT_PhieuMuon ))
				
			print N'Mã đầu sách' +SPACE(4) +N'Tên đầu sách' +SPACE(20) + N'Số cuốn đang mượn' +SPACE(4) + N'Số cuốn hiện còn'
			print CAST(@ISBN AS nvarchar(12)) + SPACE(4) + @TenSach + SPACE(30 - LEN(@TenSach)) + CAST(@SoSachMuon AS varchar(2)) + SPACE(16) + CAST(@SoSachConLai AS nvarchar(2))
			FETCH NEXT FROM CUR into @ISBN , @TenSach ,@SoSachMuon
	END		
	CLOSE CUR
	DEALLOCATE CUR
	GO
	EXEC DS_DauSach '116525441'

--3--
CREATE PROC ThongKe @Thang int , @Nam int
AS
     DECLARE CUR CURSOR FOR (SELECT COUNT (DISTINCT madg) AS N'Số lượng đọc giả', (SELECT isbn FROM 
	                          (SELECT isbn, COUNT(MaPM) AS Soluong 
							   FROM CT_PhieuMuon
	                           GROUP BY isbn) AS dg WHERE Soluong >= ALL (SELECT COUNT(MaPM) AS Soluong 
							                                            FROM CT_PhieuMuon
	                                                                    GROUP BY isbn)) AS N'Đầu Sách mượn nhiều nhất', SUM(tienphat) AS N'Tổng tiền phạt'
	                         FROM PhieuMuon JOIN CT_PhieuMuon ON PhieuMuon.MaPM= CT_PhieuMuon.MaPM 
	                                        JOIN PhieuTra ON PhieuMuon.MaPM = PhieuTra.MaPM 
	                                        JOIN CT_PhieuTra ON PhieuTra.mapt = CT_PhieuTra.mapt
	                         WHERE MONTH(ngaytra) <= @Thang AND YEAR(ngaytra) <= @Nam)

	OPEN CUR
	DECLARE @SoDocGia char(2) , @DauSach char(10), @TienPhat float
	FETCH NEXT FROM CUR into @SoDocGia  , @DauSach , @TienPhat
	WHILE (@@FETCH_status = 0)
	BEGIN
		   print N'Tháng:' + SPACE(2) + '0' + CAST(@Thang AS char(2)) + '/' + CAST(@Nam AS char(4))
		   print N'Số lượng đọc giả mượn sách:' + SPACE(2) + @sodocgia
		   print N'Đầu sách được mượn nhiều nhất:' + SPACE(2) + @DauSach
		   print N'Tổng số tiền phạt do trả trễ:' + SPACE(2) + CAST(ISNULL(@TienPhat, '-')AS char(10))
		  FETCH NEXT FROM CUR into @SoDocGia, @DauSach, @TienPhat
	END
	CLOSE CUR
	DEALLOCATE CUR
	GO
	EXEC ThongKe '9' ,'2020'

--4--

CREATE PROC MuonSach 
AS
BEGIN
	DECLARE @MaPM char(10), @tinhtrang nvarchar(15),@ISBN nchar(12),@masach nchar(5),@TenSach nvarchar(20)
	DECLARE CUR_A Cursor FOR (SELECT pm.MaPM 
						     FROM phieumuon pm)
	OPEN CUR_A
	FETCH NEXT FROM CUR_A into @MaPM 
	WHILE(@@FETCH_status = 0)
	BEGIN
		print N'Mã phiếu mượn: ' + @MaPM 
		if NOT EXISTS(SELECT MaPM FROM phieutra WHERE MaPM = @MaPM) 
			SET @tinhtrang = N'chưa trả xong'
		else
			SET @tinhtrang = N'đã trả xong'
		print N'Tình trạng: ' + @tinhtrang 
		if(@tinhtrang = N'chưa trả xong')
			BEGIN
				print N'Danh sách sách chưa trả:'
				print 'ISBN' + SPACE (6) + 'MaSach' + SPACE(5) + 'TenSach' 
				DECLARE CUR_B CURSOR FOR ( SELECT ctpm.isbn, ctpm.masach, ds.tensach 
								FROM ct_phieumuon ctpm, cuonsach cs, dausach ds
								WHERE ctpm.isbn = cs.isbn AND ctpm.masach = cs.masach
								AND cs.isbn = ds.isbn 
								AND ctpm.MaPM = @MaPM) 
				OPEN CUR_B
				FETCH NEXT FROM CUR_B into @ISBN, @masach, @TenSach 
				WHILE(@@FETCH_status = 0)
					BEGIN
						print RTRIM(@ISBN) + SPACE(1) + @masach + SPACE(6) + @TenSach
						FETCH NEXT FROM CUR_B into @ISBN, @masach, @TenSach 
					END
				CLOSE CUR_B
				DEALLOCATE CUR_B 
			END
		else
		FETCH NEXT FROM CUR_A into @MaPM 
	END
	CLOSE CUR_A
	DEALLOCATE CUR_A 
END
GO
EXEC MuonSach 