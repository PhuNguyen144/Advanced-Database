--1--
CREATE
--ALTER
PROC sp_001
    @MaPM CHAR(10)
AS
    --Extract author's info--
    DECLARE @HoTen NVARCHAR(30),@NgayMuon DATE

    SELECT @HoTen = HOTEN,@NgayMuon=ngaymuon
    FROM DocGia dg JOIN PhieuMuon pm ON dg.madg = pm.madg
    WHERE  pm.mapm=@MaPM

    PRINT N'Mã PM:' + @MaPM
    PRINT N'Ngày mượn:' + CAST(@NgayMuon AS NVARCHAR(20))
    PRINT N'Họ Tên độc giả:' + @HoTen

    --Declare CURSOR--
    DECLARE CUR CURSOR FOR (SELECT ds.isbn, ctpm.masach, ds.tensach
                            FROM DauSach ds JOIN CT_PhieuMuon ctpm ON ctpm.isbn=ds.isbn
                            WHERE ctpm.mapm = @MaPM
                            )
    SELECT * FROM PhieuMuon
    --Open Cursor--
    OPEN CUR
    --Tranfer data 1st time into CUR--
    DECLARE @ISBN NCHAR(12), @MaSach NCHAR(5), @TenSach NVARCHAR(100)

    FETCH NEXT FROM CUR INTO @ISBN, @MaSach,@TenSach
    PRINT N' Danh sách các sách mượn'
    PRINT N'=========================================================='
    PRINT N'ISBN' + SPACE(10) + N'MaSach' +SPACE(10) + N'TenSach'
    PRINT N'=========================================================='
    --Browser CUR--
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        --Proceed data--
        PRINT @ISBN + SPACE(5) + @MaSach + SPACE(5) + @TenSach
        FETCH NEXT FROM CUR INTO @ISBN, @MaSach,@TenSach
    END
    --Close Cursor
    CLOSE CUR
    --Destruct memory--
    DEALLOCATE CUR
GO
EXEC sp_001 'PM003          '

--2--
GO
CREATE
--ALTER
PROC sp_002
    @MaPT CHAR(10)
AS
    --Declare CURSOR--
    DECLARE CUR CURSOR FOR (SELECT DS.isbn, CTPT.masach, DS.tensach, DATEDIFF (DAY,PM.ngaymuon,PT.ngaytra) AS TONG_NGAY_MUON
                            FROM DauSach DS 
                            JOIN CT_PhieuTra CTPT
                            ON CTPT.isbn = DS.isbn
                            JOIN PhieuTra PT
                            ON PT.mapt = CTPT.mapt
                            JOIN PhieuMuon PM 
                            ON PM.mapm = PT.mapm
                            WHERE CTPT.mapt = @MAPT)
    --Open Cursor--
    OPEN CUR
    --Tranfer data 1st time into CUR--
    DECLARE @ISBN NCHAR(12), @MaSach NCHAR(5), @TenSach NVARCHAR(100),@SoNgayMuon INT

    FETCH NEXT FROM CUR INTO @ISBN, @MaSach,@TenSach,@SoNgayMuon
    PRINT N' Danh sách số sách trả'
    PRINT N'====================================================================================================='
    PRINT N'ISBN' + SPACE(10) + N'MaSach' +SPACE(10) + N'TenSach'+SPACE(8)+N'Số ngày mượn'
    PRINT N'====================================================================================================='
   --Browser CUR--
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        --Proceed data--
        PRINT @ISBN + SPACE (4)+ @MaSach + SPACE(4) + @TenSach + SPACE(10-LEN(CAST(@SoNgayMuon AS VARCHAR(5)))) + CAST(@SoNgayMuon AS VARCHAR(5)) 
        FETCH NEXT FROM CUR INTO @ISBN, @MaSach, @TenSach, @SoNgayMuon
    END
    --Close Cursor
    CLOSE CUR
    --Destruct memory--
    DEALLOCATE CUR
GO
EXEC sp_002 'PT002        '