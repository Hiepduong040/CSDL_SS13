use ss13;
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100),
    available_seats INT NOT NULL
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
INSERT INTO students (student_name) VALUES ('Nguyễn Văn An'), ('Trần Thị Ba');

INSERT INTO courses (course_name, available_seats) VALUES 
('Lập trình C', 25), 
('Cơ sở dữ liệu', 22);

-- 2
set autocommit = 0;
DELIMITER &&

create procedure register_course(
    in p_student_name varchar(50),
    in p_course_name varchar(100)
)
begin
    declare available int;
    declare student_id int;
    declare course_id int;
    
    -- bắt đầu transaction
    start transaction;

    -- lấy student_id từ tên sinh viên
    select student_id into student_id
    from students
    where student_name = p_student_name;

    -- lấy course_id và available_seats từ tên môn học
    select course_id, available_seats into course_id, available
    from courses
    where course_name = p_course_name;

    -- kiểm tra nếu còn chỗ trống
    if available > 0 then
        -- thêm sinh viên vào bảng enrollments
        insert into enrollments (student_id, course_id)
        values (student_id, course_id);

        -- giảm số chỗ trống của môn học đi 1
        update courses
        set available_seats = available_seats - 1
        where course_id = course_id;

        -- commit transaction
        commit;
    else
        -- nếu không còn chỗ trống, rollback giao dịch
        rollback;
    end if;

end &&

DELIMITER &&;

-- 3
call register_course('Nguyễn Văn An', 'Lập trình C');
select * from enrollments;
select * from courses;
