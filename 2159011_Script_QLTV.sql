--Q1--
select hoten, socmnd
from DocGia
where diachi like '%TP.HCM' and YEAR(GETDATE()) - YEAR(ngsinh) > 30

--Q2--
select hoten, socmnd
from DocGia 
where gioitinh = N'Nữ' and (email like 'C%' or email like 'T%')
order by socmnd asc

--Q3--
select tensach
from DauSach
where soluong between 3 and 10
order by soluong desc

--Q4--
select dg.hoten, dg.socmnd
from DocGia dg join PhieuMuon pm on dg.madg = pm.madg
where DAY(pm.ngaymuon) = 20 and MONTH(pm.ngaymuon) = 12

--Q5--
select distinct dg.hoten, dg.socmnd
from DocGia dg join PhieuMuon pm on dg.madg = pm.madg join CT_PhieuMuon on pm.mapm = CT_PhieuMuon.mapm
            join CuonSach cs on CT_PhieuMuon.isbn = cs.isbn and CT_PhieuMuon.masach = cs.masach
            join DauSach ds on ds.isbn = cs.isbn
where ds.tensach = N'Toán cao cấp A1'

--Q6--
select isbn, tensach
from DauSach 
where namxb <= all ( select namxb
                     from DauSach )

--Q7--
select hoten, socmnd
from DocGia 
where gioitinh = N'Nam' and  ngsinh <= all ( select ngsinh
                                             from DocGia
                                             where gioitinh = N'Nam' )

--Q8--
select tensach
from DauSach
where mucgiaphat <= all ( select mucgiaphat
                          from DauSach )

--Q9--
select ds.tensach
from DauSach ds
where ds.isbn in( SELECT isbn
				FROM PhieuMuon pm join CT_PhieuMuon ctpm on pm.mapm= ctpm.mapm join DocGia dg_1 on dg_1.madg = pm.madg 
				WHERE YEAR(dg_1.ngsinh) = 1974 or YEAR(dg_1.ngsinh) = 1986 or YEAR(dg_1.ngsinh) = 1990 or YEAR(dg_1.ngsinh) = 1992)

--Q10--
SELECT dg.hoten , dg.socmnd
FROM DocGia dg
WHERE dg.email is not null and madg not in
(Select madg
 FROM DauSach ds join CT_PhieuMuon ctpm on ds.isbn = ctpm.isbn join PhieuMuon pm on pm.mapm = ctpm.mapm
 WHERE namxb = 2000 or namxb = 2005 or namxb = 2009)


 --Q12--
SELECT DocGia.hoten , DocGia.socmnd
FROM DauSach ds join CT_PhieuMuon ctpm on ds.isbn = ctpm.isbn join PhieuMuon pm on pm.mapm =ctpm.mapm join PhieuTra on pm.mapm = pm.mapm join DocGia on DocGia.madg = pm.madg
WHERE ds.mucgiaphat - (day(PhieuTra.ngaytra) - day(pm.ngaymuon) -ctpm.songayquydinh) >= all(SELECT ds.mucgiaphat - (day(PhieuTra.ngaytra) - day(pm_1.ngaymuon) -ctpm_1.songayquydinh) 
																												FROM DauSach ds join CT_PhieuMuon ctpm_1 on ds.isbn = ctpm_1.isbn join PhieuMuon pm_1 on pm_1.mapm =ctpm_1.mapm join PhieuTra pt on pm_1.mapm = pt.mapm )