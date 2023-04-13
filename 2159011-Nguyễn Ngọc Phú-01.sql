--2159011_Nguyễn Ngọc Phú_01--

select * from Khoa
select * from GiangVien
select * from NhomNC
select * from ThanhVien_NNC
select * from DeTaiNCC
select * from HocVi
select * from HocVi_QuaTrinh
select * from TacGiaSP
select * from SanPhamDT


--1--
create proc cau1 
	@MaGV varchar(10), @MaNhom varchar(10)
as
begin
       if not exists(select MaGV 
					from GiangVien 
					where MaGV = @MaGV)
	   begin
	        raiserror(N'Mã giảng viên không tồn tại',15,1)
			return
	   end
	   else if not exists(select MaNhom 
							from NhomNC
							where MaNhom = @MaNhom)
       begin
	        raiserror(N'Mã NNC không tồn tại',15,1)
			return
	   end
	   else
		   begin
		   if not exists(select gv.MaGV , gv.MaKhoa, nnc.MaNhom 
						from GiangVien gv join Khoa k on gv.MaKhoa = k.MaKhoa join NhomNC nnc on k.MaKhoa = nnc.MaKhoa
						 where gv.MaGV = @MaGV and nnc.MaNhom = @MaNhom and gv.MaKhoa = nnc.MaKhoa)
					begin
					   raiserror(N'Giảng viên khong cùng khoa với nhóm NC',15,1);
					   return;
					end
			else
				 begin
					 if exists (select count(MaNhom) from ThanhVien_NNC
								 group by MaGV
								 having count(MaNhom)>=2 )
								 begin
										raiserror(N'Mỗi giảng viên chỉ dc tham gia tối đa 2 nhóm',15,1)
										return
								 end
					  else
					     
						   begin 
					   
								insert into ThanhVien_NNC (MaNhom,MaGV)
								values(@MaNhom, @MaGV)
						   end
				 end
		end
end
go

--2--
declare cur cursor for (select MaNhom, TenNhom
                            from NhomNC
                            where DATEDIFF(yy, NgayLapNhom, GETDATE()) <= 3) 
    open cur
        declare @manhom varchar(5), @tennhom nvarchar(20), @MaGV varchar(5), @TenGV nvarchar(20)
        fetch next from cur into @manhom, @tennhom

        while (@@FETCH_STATUS = 0)
        begin
            declare @solantgchinh int, @solandongtg int

            print N'Mã nhóm: ' + @manhom
            print N'Tên nhóm nghiên cứu: ' + @tennhom
            print N'Danh sách thành viên: '

            declare cur_tv cursor for ( select GiangVien.MaGV, GiangVien.HoTen
                                        from ThanhVien_NNC join GiangVien on ThanhVien_NNC.MaGV = GiangVien.MaGV
                                        where MaNhom = @manhom )
            open cur_tv
                fetch next from cur_tv into @MaGV, @TenGV
                declare @SLtgChinhNhieuNhat int = 0, @tentgChinhNhieuNhat nvarchar(20) = 'a'

                while (@@FETCH_STATUS = 0)
                begin

                    print N'Mã giảng viên' + space(5) + N'Tên giảng viên' + space(6) + N'Số lần tác giả chính' + space(5) + N'Số lần đồng tác giả'
                    print space(3) + @MaGV + space(12) +  @TenGV + space(28 - len(@TenGV)) + cast(isnull(@solantgchinh, 0) as varchar(5)) + space(23) + cast(isnull(@solandongtg, 0) as varchar(5))
                    fetch next from cur_tv into @MaGV, @TenGV
                end
            close cur_tv
            deallocate cur_tv

            print N'Thành viên là tác giả chính nhiều nhất trong nhóm: ' + cast(@SLtgChinhNhieuNhat as varchar(5)) + '-' + @tentgChinhNhieuNhat
            print '-------------------------------------------------------------------------------------'
            fetch next from cur into @manhom, @tennhom
        end
    close cur
    deallocate cur