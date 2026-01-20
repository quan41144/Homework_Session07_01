-- Create database Homework_session07_01
create database Homework_session07_01;
-- Create table book
create table book(
	book_id serial primary key,
	title varchar(255),
	author varchar(100),
	genre varchar(50),
	price decimal(10,2),
	description text,
	created_at timestamp default current_timestamp
);

-- Tạo các chỉ mục phù hợp để tối ưu truy vấn
select * from book where author ilike '%Rowling%';
select * from book where genre = 'Fantasy';
-- Kích hoạt extension cho tìm kiếm text nâng cao
create extension if not exists pg_trgm;

create index idx_book_author_trgm on book using gin(author gin_trgm_ops);

create index idx_book_genre on book(genre);

-- So sánh thời gian truy vấn trước và sau khi tạo Index (dùng EXPLAIN ANALYZE)
explain analyze select * from book where genre = 'Fantasy';
-- Thử nghiệm các loại chỉ mục khác nhau
-- B-tree cho genre
explain analyze select * from book where genre = 'Fantasy';
-- Chưa có gin index
explain analyze select * from book where description ilike '%magic%';
-- GIN cho description (phục vụ tìm kiếm full-text)
create index idx_book_description_gin on book using gin(description gin_trgm_ops);
-- Kiểm tra hiệu suất
explain analyze select * from book where description ilike '%magic%';

-- Tạo một Clustered Index (sử dụng lệnh CLUSTER) trên bảng book theo cột genre và kiểm tra sự khác biệt trong hiệu suất
cluster book using idx_book_genre;
analyze book;

-- Viết báo cáo ngắn (5-7 dòng) giải thích
-- Loại chỉ mục nào hiệu quả nhất cho từng loại truy vấn?
-- Hiệu quả của Index B-tree:
-- Tối ưu nhất cho các truy vấn so sánh bằng (=) và phạm vi (<,>), phù hợp cho cột  genre, price.
-- Hiệu quả của Index gin (với pg_trgm):
-- Tối ưu nhất cho tìm kiếm văn bản chứa ký tự đại diện (ilike, '%...%') hoặc full-text search, phù hợp cho title, author.
-- Hiệu quả của Clustered index:
-- Tối ưu hóa cách cơ sở dữ liệu đọc và ghi dữ liệu từ ổ đĩa vật lý cho các truy vấn dữ liệu theo nhóm lớn (như lấy toàn bộ sách cùng thể loại)

-- Khi nào Hash index không được khuyến khích trong PostgreSQL?
-- Vì khi cần sắp xếp với order by, không được hỗ trợ các toán tử so sánh (>,<,between), chỉ hiệu quả với so sánh bằng (=).