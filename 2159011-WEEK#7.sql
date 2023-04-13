--6--
CREATE 
FUNCTION UF_sophieumuon   (@MaDocGia varchar (10))
RETURNs int 

BEGIN 
IF NOT EXISTS (SELECT * FROM DocGia where madg =@MaDocGia) 
return 0

Declare @sophieumuon int 

SELECT @sophieumuon  = count (distinct mapm)  
FROM PhieuMuon 
where madg = @MaDocGia

return @sophieumuon 
end 


--7--
go
CREATE 
function UF_sosachmuon (@MaDocGia varchar(10) , @ngaymuon date) 
returns int 
begin

IF NOT EXISTS (SELECT * FROM DocGia where madg =@MaDocGia ) 
return 0 
IF NOT EXISTS (SELECT * FROM PhieuMuon where ngaymuon=@ngaymuon ) 
return 0
Declare @sosach int 
SELECT @sosach = count (distinct mapm) 
FROM PhieuMuon 
WHERE madg = @MaDocGia and ngaymuon =@ngaymuon

return @sosach  
end

--8--
go
CREATE 
FUNCTION UF_tinhtuoi ( @ngaysinh date)
returns int 
begin 
Declare @tuoi int
set @tuoi= DATEDIFF(year, GETDATE(), @ngaysinh) ;
 
return  @tuoi 
end
go 
---15
CREATE FUNCTION ds_docgiaMuon (@tuoi int, @gioitinh nvarchar(10))
Returns table 
 
Return (Select * FROM DocGia join PhieuMuon on PhieuMuon.madg=DocGia.madg where gioitinh =@gioitinh and   DATEDIFF(year, GETDATE(), Docgia.ngsinh)  = @tuoi)

go  

---16 
CREATE FUNCTION ds_muon (@mapm nvarchar(10))
Returns table 

Return(Select CT_PhieuMuon.mapm , PhieuMuon.ngaymuon , CT_PhieuMuon.isbn , CT_PhieuMuon.masach,CT_PhieuMuon.songayquydinh  FROM CT_PhieuMuon join PhieuMuon on CT_PhieuMuon.mapm = PhieuMuon.mapm
Where CT_PhieuMuon.mapm=@mapm 

)
--17 
go

CREATE 
FUNCTIOn  ds_tra (@mapm nvarchar(10)) 
returns table 

RETURN (
SELECT CT_PhieuTra.* , PhieuTra.mapm
FROM CT_PhieuTra join PhieuTra on CT_PhieuTra.mapt = PhieuTra.mapt
where PhieuTra.mapm = @mapm




)

