create proc cau_1 
	@MaGV char(10), @MaNhom char(10)
as
begin
	if not exists (select MaGV
					from GiangVien
					where MaGV = @MaGV
					)
	begin
        raiserror ('DATA DOES NOT EXIST',15,1)
        return
    end

	if not exists (select MaNhom
					from NhomNC
					where  MaNhom = @MaNhom)
	begin
        raiserror ('DATA DOES NOT EXIST',15,1)
        return
    end

	begin
		if (select count(MaGV) as sogv
			from ThanhVien_NNC
			where MaNhom = @MaNhom) >= 3
		begin 
			raiserror ('Nhom da du',15,1)
			return
		end
		else
		begin
		 if exists (select MaGV
					from ThanhVien_NNC
					where MaNhom = @MaNhom and MaGV = @MaGV )
			begin 
				raiserror ('Giang vien da trong nhom',15,1)
				return
			end	
		else
		begin
			if (select count(MaNhom)
				from ThanhVien_NNC
				where MaGV = @MaGV and NgayRoiNhom is null) > 2
			begin
				raiserror ('Giang vien da tham gia tren 2 nhom', 15, 1)
				return
			end
			else
			begin
				insert into ThanhVien_NNC (MaNhom, MaGV, NgayVaoNhom, NgayRoiNhom)
				values (@MaNhom, @MaGV, getdate(), null)
			end
		end
	end
end
end


create proc cau_2 


CREATE PROCEDURE sp_ThongTinThamGiaNghienCuu
    @MaGV VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @HoTen NVARCHAR(50), @SoNhom INT, @NhomDangThamGia NVARCHAR(100);
    DECLARE @LichSuThamGia NVARCHAR(MAX) = '';
    
    -- Lấy thông tin giảng viên
    SELECT @HoTen = HoTen FROM GiangVien WHERE MaGV = @MaGV;
    
    -- Lấy số lượng nhóm đã tham gia của giảng viên
    SELECT @SoNhom = COUNT(*) FROM ThamGiaNhom WHERE MaGV = @MaGV;
    
    -- Lấy tên nhóm nghiên cứu đang tham gia của giảng viên
    SELECT @NhomDangThamGia = NH.TenNhom 
    FROM ThamGiaNhom TN
    INNER JOIN NhomNghienCuu NH ON TN.MaNhom = NH.MaNhom
    WHERE TN.MaGV = @MaGV AND TN.TinhTrang = 'Đang tham gia';
    
    -- Ghi lại thông tin giảng viên
    SELECT @LichSuThamGia = CONCAT('• Mã GV: ', @MaGV, ' Họ tên: ', @HoTen);
    SELECT @LichSuThamGia = CONCAT(@LichSuThamGia, CHAR(10), '• Số nhóm từng tham gia nghiên cứu (đã rời nhóm): ', @SoNhom);
    SELECT @LichSuThamGia = CONCAT(@LichSuThamGia, CHAR(10), '• Nhóm nghiên cứu đang tham gia: ', @NhomDangThamGia, '.');
    
    -- Lấy lịch sử tham gia nghiên cứu của giảng viên bằng cách sử dụng cursor
    DECLARE @MaNhom VARCHAR(10), @VaiTro NVARCHAR(50), @TinhTrang NVARCHAR(50);
    DECLARE curThamGiaNhom CURSOR FOR
    SELECT MaNhom, VaiTro, TinhTrang
    FROM ThamGiaNhom
    WHERE MaGV = @MaGV
    ORDER BY MaNhom;
    
    OPEN curThamGiaNhom;
    FETCH NEXT FROM curThamGiaNhom INTO @MaNhom, @VaiTro, @TinhTrang;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @LichSuThamGia = CONCAT(@LichSuThamGia, CHAR(10), '• ', @MaNhom, ' - ', @VaiTro, ' - ', @TinhTrang);
        FETCH NEXT FROM curThamGiaNhom INTO @MaNhom, @VaiTro, @TinhTrang;
    END;
    
    CLOSE curThamGiaNhom;
    DEALLOCATE curThamGiaNhom;
    
    --
